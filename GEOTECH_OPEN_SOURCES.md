# 岩土 / 土木工程开放文献源 —— 访问矩阵

> 测试时间：2026-04-16
> 测试者：Claude（Anthropic 服务器出口 IP）+ 本地 Playwright（用户本机 IP）
> 基准作者：Rodrigo Salgado + Monica Prezzi（Purdue 桩基/CPT 方向）

---

## ✅ 一档：直接 WebFetch 可拿（最省事）

| 源 | URL | Salgado 命中 | Prezzi 命中 | 备注 |
|---|---|---|---|---|
| engrXiv | engrxiv.org | 0 | 0 | 类 arXiv 工程预印本，PDF 直下已验证 |
| EarthArXiv | eartharxiv.org | 0 | 0 | 地球科学/灾害方向 |
| Zenodo API | `zenodo.org/api/records?q=...` | 0 | 0（有 "M. Prezzi" 但非同一人） | 全库 2318 条 geotech 结果，CC 许可 |
| USGS Pubs | pubs.usgs.gov | — | — | 18 万 + 出版物，开放 |
| NIST Pubs | nvlpubs.nist.gov | — | — | 开放 |
| arXiv physics.geo-ph | arxiv.org/list/physics.geo-ph/recent | — | — | 偶有相关，但不是岩土主战场 |
| FHWA（旧站） | www.fhwa.dot.gov/engineering/geotech/ | — | — | 用 `www.fhwa.dot.gov`，不要用新的 `highways.dot.gov`（被封） |
| Purdue e-Pubs / JTRP | docs.lib.purdue.edu/jtrp | 15+ | 同（合著） | 最大金矿，所有 INDOT 项目报告，PDF 直下 |

## ⚠️ 二档：本地 Playwright 才能进（WebFetch 被 403）

| 源 | URL | Salgado/Prezzi | 备注 |
|---|---|---|---|
| ISSMGE Online Library | issmge.org/publications/online-library | 16 + 8（有重叠） | 岩土圈最对口的源，PDF 无登录直下，已验证 |
| ROSA-P (USDOT) | rosap.ntl.bts.gov | 未测 | 落地页 OK，搜索 URL 格式不明 |
| USACE 数字图书馆 | usace.contentdm.oclc.org | — | CONTENTdm 系统，需要 Playwright 等 JS 加载 |
| National Academies | nationalacademies.org/publications/<id> | — | 页面可看；PDF 需注册 MyAcademies 账号（免费） |
| DTIC 落地页 | discover.dtic.mil | — | 落地可看；具体报告 URL 仍 Request Blocked |

## ❌ 三档：彻底封死（WebFetch + Playwright 都进不去）

- ASCE Library（ascelibrary.org）— Cloudflare Turnstile，需要人机验证
- SSRN — Cloudflare Turnstile
- TechRxiv（IEEE）— Cloudflare Turnstile
- CORE.ac.uk — Cloudflare Turnstile
- Preprints.org（MDPI）— Access Denied（站点级）
- BASE-search.net — Anubis 反爬
- HAL.science（法国预印本）— Anubis 反爬（你自己的浏览器能上）
- highways.dot.gov — Access Denied（改用 `www.fhwa.dot.gov` 旧站）
- DTIC apps.dtic.mil — 具体报告 Request Blocked，多数全文需 CAC 卡
- ASCE / Elsevier ScienceDirect / Wiley / Springer — 全部付费墙；Purdue EZproxy 需要你本人 SSO cookie，我无法继承

---

## ISSMGE 抓取技术备忘

- 作者搜索框是 Select2，原生 `.click()` 选不上选项；要 dispatch `mousedown` + `mouseup` + `click` 三个 MouseEvent
- 一旦拿到作者 ID，可以直接 GET：`issmge.org/publications/online-library?authors[]=<id>`
- 已知 ID：
  - Rodrigo Salgado = 152956
  - Monica Prezzi = 151930
  - R. Salgado（疑似不同人）= 166079
- `/online-library/authors?term=...` 端点会忽略 term，直接返回 ~3MB 全库作者表，可离线 grep

## 工作流建议

1. 先用 WebFetch 试（最快、免费）
2. 403 / 空白 → 切 本地 Playwright（用你的 IP，绕过 gov 站点的 geo-fence）
3. 撞 Cloudflare Turnstile / Anubis → 放弃自动化
4. 付费期刊：Unpaywall API（`api.unpaywall.org/v2/<DOI>?email=...`）合法找开放版

## 保存路径

- 所有下载到的参考资料 (论文 PDF、技术报告、数据集、网页存档、截图、CSV 等) 均保存到 `Abaqus2024/literature/` 下
- 每份资料在 `Abaqus2024/literature/MANIFEST.md` 中登记。结构: 顶部一张汇总表, 表下方每条 entry 一个小节, 内含 BibTeX 块 (可直接导入 Mendeley) + 抓取信息。示例:

~~~markdown
## 总表

| 文件名 | 标题 | 第一作者 | 年份 | 类型 | 用途 |
|---|---|---|---|---|---|
| salgado_2008_engineering.pdf | The Engineering of Foundations | Salgado | 2008 | book | 桩基承载力参考 |

## 详细

### salgado_2008_engineering.pdf

- 来源: Purdue e-Pubs / JTRP, 抓取 Playwright @ 2026-04-16, 许可未知

```bibtex
@book{salgado2008engineering,
  author    = {Salgado, Rodrigo},
  title     = {The Engineering of Foundations},
  year      = {2008},
  publisher = {McGraw-Hill}
}
```
~~~