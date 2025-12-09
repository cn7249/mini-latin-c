# Latin C Compiler

Latin C는 다음을 목표로 하는 실험적 컴파일러 프로젝트입니다:

- C 언어의 mini C subset을 기반으로 구현
- 모든 키워드를 라틴어로 대체
- 로마 숫자 인식
- 함수 인자 전달 시 목적격 활용
- 코드 시작 구문 필수('#include <stdio.h>' 대체):  
  **Ave Imperator, morituri te salutant.**

## 언어 특징 요약

### 라틴어 기반 키워드

## 지원되는 기능

### 1. **프롤로그(Preamble)**
모든 프로그램은 반드시 아래 문장으로 시작해야 한다:

```latin
Ave Imperator, morituri te salutant.
```

### 2. 함수 선언
프로그램은 하나의 principalis(main) 함수만 가진다:

```latin
integer principalis(vacuum) {
    ...
}
```

### 빌드(Build) 및 실행

```bash
make
./latin-c program.lc
```