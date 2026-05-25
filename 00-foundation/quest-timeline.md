---
type: foundation
updated: 2026-05-24
version: 2 (job-ASAP rewrite)
---

# Quest Timeline — 4-Week Sprint to Applying

Adventurer: 25, sysadmin at a nonprofit foundation, pivoting to **Cloud Engineer / Junior DevOps / Sysadmin-SRE / IAM** roles. Target: applications going out by **2026-06-21** (4 weeks from today, 2026-05-24).

## The honest reordering

The previous timeline was a "learn cleanly" plan. This one is a "get interviews" plan. Three rules drive it:

1. **Portfolio before cert.** A recruiter scans your GitHub in 30 seconds. The cert is a checkbox; the portfolio is the proof.
2. **Cert in progress beats no cert.** Schedule the exam now. "AWS CCP, exam scheduled 2026-06-28" on a resume reads the same as "AWS CCP, passed" for the first 3 weeks of applications.
3. **Hub stays at "good enough."** It already captures notes. Stop polishing it. Polish the things recruiters see.

## Cert decision: AWS CCP first

You said "don't know yet / both." Default = **AWS Cloud Practitioner (CLF-C02)** because:
- 70%+ of US cloud job postings are AWS.
- Same difficulty as AZ-900, same 2-4 week study window, ~$100 exam.
- Pairs perfectly with porting your existing Terraform LocalStack lab to real AWS (one quest, two outcomes).
- If an Azure-shop interview lands, you can pivot and add AZ-900 in month 2.

**IAM angle:** if any of your top applications are IAM-focused (Okta, Azure Entra, AWS IAM specialist), add **AWS Certified Security – Specialty** or **SC-900 (Microsoft Security Fundamentals)** to month 2 plan. SC-900 is the IAM-adjacent AZ-900.

## The map

```
WEEK 1 ─────► WEEK 2 ─────► WEEK 3 ─────► WEEK 4 ─────► WEEK 5+
Portfolio     Real AWS      Resume +      APPLY         Interview prep
polish        + CI lab      LinkedIn      (volume)      + cert exam
+ CCP study   + CCP study   + CCP study                 (2026-06-28)
```

## Week 1 (2026-05-24 → 2026-05-31): Portfolio polish + cert kickoff

**Theme: make your GitHub legible in 30 seconds. Start cert study.**

| Day | Quest | Effort | Why |
|---|---|---|---|
| Today | **Schedule AWS CCP exam for 2026-06-28** at aws.amazon.com/certification | 15 min | Locks the deadline. Drives study. |
| Today | Buy/start **Stephane Maarek's AWS CCP course** on Udemy (~$15 on sale) | 30 min | Best-in-class CCP prep. |
| Day 2 | Rewrite the **root README.md** of this repo for recruiter eyes: who you are, what you're learning, links to the 3 best projects | 1 hr | This is the page recruiters land on. |
| Day 2 | Add **GitHub Actions CI** to terraform-localstack-s3-lab (`fmt -check`, `validate`, `plan` on PR). Get the green badge. | 2 hrs | Signals you know CI/CD basics. |
| Day 3 | Write `01-guides/terraform-from-zero-with-localstack.md` (polish the lab README into a teaching guide) | 2 hrs | First flagship guide. Shareable on LinkedIn. |
| Day 4 | Write `01-guides/minecraft-server-on-ubuntu-vps.md` from your 2026-05-21 notes | 2 hrs | Second flagship guide. Shows Linux depth. |
| Day 5 | Add `04-cheatsheets/terraform.md` and `04-cheatsheets/systemd.md` | 1 hr | Cheap content density. |
| Weekend | CCP study: Modules 1-3 (Cloud Concepts, Security, Tech) | 4 hrs | Stay on pace for 6/28 exam. |
| Sunday | **Pin your 3 best repos** on GitHub profile. Write a profile README. | 30 min | The first thing a recruiter sees. |

**End of week deliverable:** GitHub looks like a person who learns in public and ships. CCP study is ~25% done.

## Week 2 (2026-05-31 → 2026-06-07): Real AWS + one more project

**Theme: one real-cloud project. Not LocalStack. Real bucket, real creds, real receipts.**

| Day | Quest | Effort | Why |
|---|---|---|---|
| Day 1 | Open AWS free-tier account. Set billing alarm at $5. | 30 min | Required for everything. |
| Day 2 | Port S3 lab to **real AWS**: delete endpoints block, fresh creds via `aws configure`, new globally-unique bucket name. Apply, verify, destroy. | 2 hrs | Real-cloud reps. |
| Day 3 | New project: `03-projects/aws-static-site/` — S3 + CloudFront for a static portfolio page, all via Terraform | 3 hrs | Visible artifact + 2nd Terraform project + uses your domain if you have one. |
| Day 4 | Write the project README with screenshots of the working site | 1 hr | Recruiter-readable proof. |
| Day 5 | Add an **IAM-flavored lab**: `03-projects/aws-iam-least-privilege/` — Terraform module that creates a role with the minimum permissions for the S3 lab. Document the policy reasoning. | 3 hrs | Hits your IAM target directly. |
| Weekend | CCP study: Modules 4-5 (Billing/Pricing, Support). Take first practice exam. | 5 hrs | Should be scoring 65%+ by Sunday. |

**End of week deliverable:** 4 public projects (2 Terraform, 1 IAM, 1 Minecraft notes). Real AWS account. CCP at ~60%.

## Week 3 (2026-06-07 → 2026-06-14): Resume, LinkedIn, target list

**Theme: package the proof. Build the funnel.**

| Day | Quest | Effort | Why |
|---|---|---|---|
| Day 1 | Run the **RPG resume forge** (this skill) against your existing resume + a real target JD | 1 hr | The actual reason this skill exists. |
| Day 2 | Rewrite **LinkedIn headline + About** to match: "Sysadmin transitioning to Cloud Engineer. Terraform, AWS, IAM. AWS CCP in progress." | 1 hr | LinkedIn is half the inbound. |
| Day 2 | Pin GitHub profile link + 2 best project links on LinkedIn featured section | 15 min | Make the proof one click away. |
| Day 3 | Build a **target list of 30 companies** hiring junior cloud/SRE/IAM. Save in `00-foundation/target-list.md`. | 2 hrs | No list = no applications. |
| Day 4 | Write a **base cover letter template** + 3 role-specific variants (Cloud Eng, SRE, IAM) | 2 hrs | Application speed multiplier. |
| Day 5 | Post **one LinkedIn build-in-public post** linking to your terraform guide. Tag #Terraform #AWS. | 30 min | Signal you exist. |
| Weekend | CCP: full practice exam #2, review wrong answers. Should be 75%+. | 5 hrs | On track for 6/28. |

**End of week deliverable:** Resume forged, LinkedIn aligned, 30 targets identified, cover letter library ready, one public post live.

## Week 4 (2026-06-14 → 2026-06-21): APPLY (volume + tracking)

**Theme: stop polishing. Send applications.**

| Day | Quest | Daily target |
|---|---|---|
| Mon | Apply to 5 jobs from target list. Log each in a Notion DB or `00-foundation/applications.md`. | 5 apps |
| Tue | Apply to 5 more. **DM the recruiter or hiring manager on LinkedIn** for at least 2 of them. | 5 apps + 2 DMs |
| Wed | Apply to 5 more. Reach out to 2 people in your existing network who work in cloud/IT. Ask for a referral or a 15-min chat. | 5 apps + 2 messages |
| Thu | Apply to 5 more. Practice CCP weak areas. | 5 apps |
| Fri | Apply to 5 more. **Recap week:** how many responses, what's the conversion, what to adjust. | 5 apps + review |
| Weekend | CCP final practice exam. Should be 80%+. Light review only. | 4 hrs |

**End of week deliverable:** 25 applications sent. Pipeline tracking live. CCP exam-ready.

## Week 5+ (2026-06-21 onward): Sustain + interview + exam

| What | When |
|---|---|
| Sustain 5 applications/day until first interview cycles arrive | ongoing |
| **AWS CCP exam** | 2026-06-28 |
| Interview prep: behavioral STAR stories from existing sysadmin work | as interviews land |
| Interview prep: Terraform live-coding (write a module from memory), Linux troubleshooting walk-throughs | as interviews land |
| Decide on second cert: AWS SAA (next cloud step), AZ-900 (if Azure shop interviews), or SC-900/AWS Security (if IAM track sticks) | after first 2 interview cycles |

## What changed from v1

| v1 (learn cleanly) | v2 (job ASAP) | Why |
|---|---|---|
| ADHD Hub finish first (week 1-2) | Hub stays at "good enough" — only finish 2-min Daily Notes plugin | Hub doesn't get you hired. Capture works already. |
| Terraform polish in week 3-4 | Terraform polish in week 1 | Recruiter-visible. Move it up. |
| AZ-900 in months 4-6 | AWS CCP scheduled for **2026-06-28**, study runs weeks 1-5 | Cert in progress > no cert. Aligns with US market. |
| Apply "eventually" | Apply starting **2026-06-14**, 5/day | Volume is the only honest job-search lever. |
| Minecraft hardening in month 2-3 | Minecraft notes → polished guide in week 1, hardening cut | The guide is the artifact. Hardening is invisible. |

## Standing rules during the sprint

- 🚫 **No new projects** until week 3 is done. Polish what exists.
- 🚫 **No new tools** until applications start. No new note app, no new shortcut, no new framework.
- ⏰ **Daily cap:** 2 hours of cert study + 1-3 hours of build/apply. Beyond that, diminishing returns at 25 with a day job.
- 📊 **Weekly review (Sundays, 20 min):** what shipped, what slipped, adjust next week.
- 🆘 **Bad day:** apply to 1 job. That's the floor. Backlog is not debt.

## Next single action (in the next 30 minutes)

1. Open https://aws.amazon.com/certification/certified-cloud-practitioner/
2. Schedule the CCP exam for **2026-06-28**.
3. Pay the fee. Forward the receipt to yourself.

The deadline is the engine. Everything else in this timeline assumes that exam date exists.
