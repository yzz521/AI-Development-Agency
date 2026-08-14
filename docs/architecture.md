# AI Development Agency Architecture

```text
                    AGENTS.md
                        |
                  Task Router
                        |
              +---------+---------+
              |                   |
           Workflow            Context
              |                   |
              +---------+---------+
                        |
                      Agent
                        |
                 Rules + Code
                        |
                    Artifact
                        |
             +----------+----------+
             |          |          |
            QA       Security    Review
             |          |          |
             +----------+----------+
                        |
                    Validation
                        |
                    Final Result
```

核心思想：Agent 不共享隐式记忆，依靠标准 Artifact 显式交接。
