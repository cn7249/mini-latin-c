# Latin C Compiler

Latin C는 mini-C 형태의 간단한 언어를 기반으로 하되,
**모든 키워드와 연산자를 라틴어로 대체하고, 로마 숫자 및 라틴식 주석을 지원하는 것을 목표로 구현된 인터프리터 기반 컴파일러 프로젝트**입니다.

본 프로젝트는 Flex/Bison을 통해 직접 제작한 Lexer/Parser를 활용하며, AST(Abstract Syntax Tree)를 구성하여 인터프리터가 실행하도록 설계하였습니다.

---

## 1. 프로젝트 개요
- 개발 목표: 고전 라틴어 기반의 독창적인 DSL(도메인 특화 언어) 제작
- 실행 구조: **Lexer -> Parser -> AST -> Interpreter**
- 언어적 특징:
  - 로마 숫자 자동 해석(I, II, V, X, IX 등)
  - 라틴어 키워드 사용
  - 라틴식 단일, 다중 주석 지원
  - main 함수에 해당하는 ```principalis``` 사용
  - 프로그램 시작을 알리는 필수 구문 존재

---

## 2. 언어 특징
### 필수 프롤로그(Preamble)
모든 프로그램은 반드시 다음 문장으로 시작해야 합니다:

```latin
Ave Imperator, morituri te salutant.
```
(한국어: 황제 폐하 만세, 곧 죽을 자들이 경의를 표합니다.)

이는 일반 C의 ```#include <stdio.h>```역할을 대신합니다.

---

### 데이터 타입
| 라틴어       | 의미               |
| --------- | ---------------- |
| `integer` | 정수형 타입           |
| `vacuum`  | 파라미터 없음(VOID 역할) |

---

### 함수(Function)
Latic C 프로그램은 반드시 하나의 주 함수인 ```principalis```를 포함해야 합니다.

```latin
integer principalis(vacuum) {
    ...
}
```

---

### 변수 선언 및 대입

```latin
integer MARCUS;
integer LUCIUS EST X;    NOTA: X는 로마 숫자 10
MARCUS EST V;            NOTA: V는 로마 숫자 5
```

대입에는 반드시 **EST** 키워드를 사용합니다.

### 로마 숫자 지원
다음과 같은 표준 로마 숫자를 모두 지원합니다.
```
I, V, X, L, C, D, M, IV, IX, XL, XC, CD, CM ...
```

예시:
| 로마 숫자 | 값    |
| ----- | ---- |
| X     | 10   |
| IV    | 4    |
| MCMXC | 1990 |

---

### 출력 (scribere)
```latin
scribere("Salve!");
scribere(A);
scribere(A PAR B);
```
문자열은 자동으로 따옴표 제거 후 출력됩니다.

---

## 3. 주석(Comment) 시스템
### 단일 라인 주석
```latin
NOTA: 이 줄 전체는 무시됩니다.
```

---

### 멀티 라인 주석(코드 블록)
```latin
EXPLANATIO:
  이 영역은 전체가 무시됩니다.
  여러 줄도 가능합니다.
FINIS
```

---

## 4. 지원되는 연산자 (Operators)
### 산술 연산자
| 의미 | 기호  |
| -- | --- |
| 덧셈 | `+` |
| 곱셈 | `*` |

---

### 비교 연산자 (라틴어 키워드)
| 의미     | 원래 기호 | 라틴어 키워드       |
| ------ | ----- | ------------- |
| 같다     | ==    | **PAR**       |
| 다르다    | !=    | **IMPAR**     |
| 작다     | <     | **MINOR**     |
| 크다     | >     | **MAIOR**     |
| 작거나 같다 | <=    | **NON_MAIOR** |
| 크거나 같다 | >=    | **NON_MINOR** |

사용 예시:
```latin
scribere(A PAR B);
scribere(A MAIOR B);
scribere(A NON_MAIOR B);
```

---

### 논리 연산자
| 의미  | 기호 | 라틴어 키워드 |
| --- | -- | ------- |
| AND | && | **ET**  |
| OR  | || | **VEL** |
| NOT | !  | **NON** |

사용 예시
```latin
scribere((A MAIOR B) ET (B PAR V));
scribere(NON(A PAR B));
```

---

## 5. 언어 문법(EBNF)
```ebnf
program        = preamble func_decl ;

preamble       = "Ave Imperator, morituri te salutant." ;

func_decl      = "integer" IDENT "(" "vacuum" ")" block ;

block          = "{" stmt_list "}" ;

stmt_list      = { stmt } ;

stmt           = var_decl ";"
               | IDENT "EST" expr ";"
               | "scribere" "(" expr ")" ";"
               | "reditus" expr ";"
               | expr ";" ;

var_decl       = "integer" IDENT
               | "integer" IDENT "EST" expr ;

expr           = NUMBER
               | STRING
               | IDENT
               | expr "+" expr
               | expr "*" expr
               | "(" expr ")"
               | expr PAR expr
               | expr IMPAR expr
               | expr MINOR expr
               | expr MAIOR expr
               | expr NON_MAIOR expr
               | expr NON_MINOR expr
               | expr ET expr
               | expr VEL expr
               | NON expr ;
```

---

## 6. 빌드 및 실행 방법
### 빌드
```bash
make
```

### 실행
```bash
./latin-c program.lc
```

---

## 7. 테스트 프로그램 10개 (기대 출력 포함)
### Test 1 - 기본 출력


## 8. 프로젝트 구조
```
src/
  lexer.l
  parser.y
  ast.c
  ast.h
  interp.c
  main.c
Makefile
README.md
```

## 9. 구현된 기능 / 미구현 기능
### 구현된 기능
- 변수 선언 및 대입
- 산술 연산(+, *)
- 비교 연산(PAR, IMPAR, MINOR, MAIOR, NON_MAIOR, NON_MINOR)
- 논리 연산(ET, VEL, NON)
- 문자열 출력
- 로마 숫자 해석기
- 라틴식 주석(NOTA:, EXPLANATIO: ... FINIS)
- AST 기반 인터프리터
- 기본 에러 메시지 출력

---
### 미구현(향후 확장 예정)
- 조건문(if, else)
- 반복문(while, for)
- 함수 호출(사용자 정의 함수)
- 타입 검사
- 에러 복구 처리

---

## 10. 개발자
najdorf / cn7249
cn7249@gmail.com
