# AWS 인프라 기본 정책 및 구성 정리

이 문서는 Spring Boot 백엔드 배포에 사용된 AWS EC2, S3, IAM 정책의 기본 구조와 실무 적용 예시를 정리한 가이드입니다.

---

## 1. EC2 (Elastic Compute Cloud)
- **역할**: 애플리케이션이 실제로 실행되는 가상 서버
- **주요 설정**
  - Amazon Linux 2 또는 Ubuntu 등으로 인스턴스 생성
  - 보안그룹에서 8080 포트(HTTP)와 22 포트(SSH) 오픈
  - SSH 키페어로 원격 접속
  - Docker, AWS CLI 등 배포에 필요한 패키지 설치

#### 예시: 보안그룹 인바운드 규칙
- 22(SSH): 내 IP만 허용 (보안)
- 8080(HTTP): 0.0.0.0/0 (테스트용, 운영 시 제한 권장)

---

## 2. S3 (Simple Storage Service)
- **역할**: 파일(이미지, 첨부 등) 저장용 스토리지
- **주요 설정**
  - 버킷 생성 (예: sk5th-kbm-s3-bucket)
  - 퍼블릭 액세스 차단(기본), 필요한 경우 정책으로 예외 허용
  - 객체 업로드/다운로드 권한은 IAM 정책으로 제어

#### 예시: S3 버킷 정책 (읽기/쓰기)
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject"
      ],
      "Resource": "arn:aws:s3:::sk5th-kbm-s3-bucket/*"
    }
  ]
}
```

---

## 3. IAM (Identity and Access Management)
- **역할**: AWS 리소스 접근 권한 관리
- **주요 설정**
  - 배포/앱용 IAM 사용자 생성 (ex: github-actions-deploy)
  - 최소 권한 원칙(Least Privilege) 적용
  - 액세스 키/시크릿 키는 GitHub Secrets 등 안전한 곳에만 저장

#### 예시: ECR, S3, EC2 배포용 IAM 정책
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:PutImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject"
      ],
      "Resource": "arn:aws:s3:::sk5th-kbm-s3-bucket/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstances"
      ],
      "Resource": "*"
    }
  ]
}
```

---

## 4. 실무 적용 포인트
- **액세스 키/시크릿 키는 절대 코드/깃에 노출 금지** (GitHub Secrets 등 안전하게 관리)
- **IAM 정책은 최소 권한만 부여**
- **S3 버킷은 퍼블릭 차단, 필요한 경우에만 예외 허용**
- **EC2 보안그룹은 꼭 필요한 포트만 오픈**

---

## 5. 참고
- AWS 공식 문서: EC2, S3, IAM, ECR 등
- 실습/운영 환경에 따라 정책은 조정 필요
- 추가 리소스(예: RDS, CloudWatch 등) 사용 시 별도 정책 필요
