#!/bin/bash
set -e

TEST_TYPE=${1:-"unit"}
PROJECT_TYPE=${2:-"java"}

case $PROJECT_TYPE in
    "java")
        case $TEST_TYPE in
            "unit") mvn test ;;
            "integration") mvn verify -Dskip.unit.tests=true ;;
            "security") mvn org.owasp:dependency-check-maven:check ;;
        esac
        ;;
    "nodejs")
        case $TEST_TYPE in
            "unit") npm run test:unit ;;
            "integration") npm run test:integration ;;
            "e2e") npm run test:e2e ;;
            "security") npm audit --audit-level=high && npx retire ;;
        esac
        ;;
    "python")
        case $TEST_TYPE in
            "unit") pytest tests/unit/ --cov=src ;;
            "integration") pytest tests/integration/ ;;
            "security") bandit -r src/ && safety check ;;
        esac
        ;;
esac

echo "Tests completed: $TEST_TYPE for $PROJECT_TYPE"