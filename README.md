# Latin C Compiler

Latin C는 mini-C 형태의 간단한 언어를 기반으로 하되,
**모든 키워드와 연산자를 라틴어로 대체하고, 로마 숫자 및 라틴식 주석을 지원하는 것을 목표로 구현된 인터프리터 기반 컴파일러 프로젝트**입니다.

본 프로젝트는 Flex/Bison을 통해 직접 제작한 Lexer/Parser를 활용하며, AST(Abstract Syntax Tree)를 구성하여 인터프리터가 실행하도록 설계하였습니다.

## 1. 프로젝트 개요
- 개발 목표: 고전 라틴어 기반의 독창적인 DSL(도메인 특화 언어) 제작
- 실행 구조: **Lexer -> Parser -> AST -> Interpreter**
- 언어적 특징:
  - 로마 숫자 자동 해석(I, II, V, X, IX 등)
  - 라틴어 키워드 사용
  - 라틴식 단일, 다중 주석 지원
  - main 함수에 해당하는 ```principalis``` 사용
  - 프로그램 시작을 알리는 필수 구문 존재

## 2. 언어 특징
### 필수 프롤로그(Preamble)
모든 프로그램은 반드시 다음 문장으로 시작해야 합니다:

```latin
Ave Imperator, morituri te salutant.
```
(한국어: 황제 폐하 만세, 곧 죽을 자들이 경의를 표합니다.)
이는 일반 C의 ```#include <stdio.h>```역할을 대신합니다.

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