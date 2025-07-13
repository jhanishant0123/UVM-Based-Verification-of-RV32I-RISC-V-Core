# UVM-Based-Verification-of-RV32I-RISC-V-Core

```mermaid
graph TD
    subgraph UVM Verification Environment
        A[UVM TEST<br>(Instantiates Environment)] --> B(ENVIRONMENT<br>(env.sv))

        subgraph Environment Components
            B --> C(AGENT<br>(agent.sv))
            B --> D(SCOREBOARD<br>(scoreboard.sv))
        end

        subgraph Agent Components
            C --> E(MONITOR<br>(monitor.sv))
            C --> F(DRIVER<br>(driver.sv))
        end

        subgraph Stimulus Generation
            H(SEQUENCE<br>(sequence)) --> G(SEQUENCER<br>(sequencer))
            G --> F
        end

        E --> D(SCOREBOARD)
    end
