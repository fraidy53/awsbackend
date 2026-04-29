# 백엔드 배포 방식 정리

이 문서는 현재 Spring Boot 백엔드의 배포 방식을 `deploy.yml`(GitHub Actions)과 `Dockerfile` 기준으로 정리한 것입니다.

---

## 1. 전체 배포 흐름 요약

1. 개발자가 main 브랜치에 push
2. GitHub Actions(`deploy.yml`)가 자동 실행
3. 소스코드 빌드(JDK 17, Gradle)
4. Docker 이미지 빌드 및 Amazon ECR에 push
5. EC2 서버에 SSH로 접속해 최신 이미지를 pull & 컨테이너 실행
6. 환경변수는 GitHub Secrets에서 안전하게 주입

---

## 2. deploy.yml (GitHub Actions)

- **트리거**: main 브랜치 push 시 자동 실행
- **주요 단계**:
  1. **Checkout**: 소스코드 체크아웃
  2. **JDK 17 세팅**: Spring Boot 빌드 환경 준비
  3. **Gradle 빌드**: bootJar 생성
  4. **AWS 인증**: IAM 키로 AWS CLI 인증
  5. **ECR 로그인**: Docker 이미지 push를 위한 인증
  6. **Docker Build & Push**: Docker 이미지 빌드 후 ECR에 push
  7. **EC2 배포**: SSH로 EC2 접속, 최신 이미지 pull, 컨테이너 실행
- **환경변수 주입**: EC2에서 docker run 시 `-e` 옵션으로 GitHub Secrets 값 전달

#### 예시 (일부)
```yaml
- name: Deploy to EC2
  uses: appleboy/ssh-action@master
  with:
    ...
    script: |
      ...
      sudo docker run -d --name aws-lab-app -p 8080:8080 \
        -e S3_BUCKET_NAME="${{ secrets.S3_BUCKET_NAME }}" \
        -e DB_URL="${{ secrets.DB_URL }}" \
        -e DB_USERNAME="${{ secrets.DB_USERNAME }}" \
        -e DB_PASSWORD="${{ secrets.DB_PASSWORD }}" \
        ${{ steps.login-ecr.outputs.registry }}/aws-lab-app:latest
```

---

## 3. Dockerfile

- **역할**: Spring Boot 애플리케이션을 컨테이너 이미지로 패키징
- **환경변수 처리**: Dockerfile에서는 ENV로 기본값만 지정하거나, 실제 값은 docker run 시 -e로 주입
- **.env 파일 사용 X**: 현재는 .env 파일을 직접 사용하지 않고, 배포 시점에 환경변수로 주입

#### 예시 (일부)
```dockerfile
# (필요시)
ENV DB_USERNAME=default_user
ENV DB_PASSWORD=default_pass
# 실제 값은 docker run -e로 덮어씀
```

---

## 4. 보안 및 관리 포인트
- **민감정보는 GitHub Secrets로만 관리**
- **.env 파일은 git에 커밋하지 않음**
- **환경변수는 배포 시점에만 주입**
- **Dockerfile에는 민감정보 직접 작성 금지**

---

## 5. 참고
- CI/CD, Docker, AWS ECR, EC2, GitHub Secrets 등 실무에서 널리 쓰는 안전한 배포 방식
- 추가적인 환경변수나 설정이 필요하면 deploy.yml과 Dockerfile을 함께 수정
