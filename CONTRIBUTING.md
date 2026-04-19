# Contributing

Thank you for helping improve WSL-Dev-Startup.

Forks are welcome, but upstream pull requests are strongly encouraged. This project is healthiest when useful fixes, compatibility updates, and workflow improvements make their way back into the main repository instead of living in scattered forks that eventually go stale.

## Upstream First

If you fix bugs, add support for new workflows, or improve compatibility, please open a pull request against the main repository. Keeping improvements centralized helps prevent stale forks and makes the tool better for everyone.

## Development Notes

* Keep changes focused and easy to review.
* Update `CHANGELOG.md` for user-facing changes.
* Update `README.md` when behavior, setup, configuration, or release flow changes.
* Preserve the local-install split: repo templates belong in source control, while machine-specific files like `data\Config.psd1`, generated backups, and customized local host parts should stay local unless the change is intentionally part of the template.
* Run basic PowerShell parse checks before opening a PR when possible.

## License

This project is licensed under GPLv3. You are free to fork, modify, and redistribute it under the license terms. If you distribute modified versions, those versions must remain available under GPLv3-compatible terms.

Pull requests back upstream are appreciated and encouraged, but they are not required by the license.
