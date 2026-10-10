# 🕹️ DevOps Playground

An open-source interactive learning platform that teaches modern DevOps, Cloud Engineering, and Site Reliability Engineering through hands-on, gamified terminal missions.

---

## 🗺️ Curriculum Roadmap

| Level | Topic | Status | Focus Areas |
| :--- | :--- | :--- | :--- |
| **Level 0** | **[Linux & The Terminal](./levels/level-0-linux/)** | 🟢 **Ready** | Filesystem navigation, POSIX permissions, log parsing, process management, SSH key auth, systemd & services, runaway process eradication. |
| **Level 1** | **Docker & Containers** | 🟡 *In Development* | Images, layers, networking, volumes, multi-stage builds, container isolation. |
| **Level 2** | **CI/CD Pipelines** | ⚪ *Planned* | GitHub Actions, automated testing, artifact caching, branch protections. |
| **Level 3** | **Kubernetes Fundamentals** | ⚪ *Planned* | Pods, Deployments, Services, ConfigMaps, Secrets, Ingress controllers. |
| **Level 4** | **Infrastructure as Code** | ⚪ *Planned* | Terraform, state management, provider configuration, drift detection. |
| **Level 5** | **Observability & SRE** | ⚪ *Planned* | Prometheus, Grafana, log aggregation, alerting thresholds, incident triage. |

---

## ⚡ Quick Start: Play Level 0

```bash
# 1. Clone the repository
git clone https://github.com/Harshit-Maurya838/devops-playground.git
cd devops-playground/levels/level-0-linux

# 2. Start the container sandbox
docker compose up -d --build

# 3. Enter the player shell
docker compose exec -u player sandbox bash

# 4. Launch the game engine
./play.sh
```

---

## 🤝 Contributing
We welcome contributions! Please review [CONTRIBUTING.md](./CONTRIBUTING.md) to add new missions, fix typos, or improve level mechanics.

---

## 📄 License
This project is open-source and licensed under the [MIT License](LICENSE).
