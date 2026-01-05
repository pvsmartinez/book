# Workshop: Auditing the Filter

The "Judge" (the Value Function) determines who wins the race. Changing the judge changes the winner.

Here are two tools to help identify what is actually being measured and how to change the outcome.

---

## Tool 1: The Lie Detector (Spotting the True Metric)

We often assume systems are optimized for their stated goals (Truth, Justice, Quality). But the pattern only optimizes for the **Feedback Loop**.

To find the truth, one must ignore the label and audit the feedback.

### Case Study: The Stock Market Guru

Consider the example of a famous financial "Guru" on YouTube. He is loud, confident, and predicts a market crash every Tuesday.

*   **The Label:** "Market Expert."
*   **The Stated Goal:** Accuracy.

**The Audit:**
1.  **Scenario A (He is Wrong):** He predicts a crash. It doesn't happen.
    *   *Consequence:* Does he lose money? No. Does he lose followers? Rarely. He says "I was early."
    *   *Feedback:* Weak/Neutral.
2.  **Scenario B (He is Boring):** He says "I don't know" or gives a nuanced, complex answer.
    *   *Consequence:* Views drop. The algorithm stops recommending him. He sells fewer courses.
    *   *Feedback:* Negative/Immediate.

**The Diagnosis:**
The system punishes nuance and rewards confidence, regardless of truth.
The Guru is not optimized for **Accuracy**. He is optimized for **Persuasion**.

**The Rule:** If the penalty for being boring is higher than the penalty for being wrong, you are looking at an Entertainment Engine, not a Truth Engine.

---

## Tool 2: The Lever (Changing the Outcome)

When the behavior of a system is undesirable, don't yell at the people inside it. They are just adapting to the metric. To change the behavior, you must change the metric.

### Case Study: The Call Center

A company wants to improve customer service.

**Attempt 1: The Wrong Metric**
*   **The Metric:** "Average Call Duration." (Shorter is better).
*   **The Logic:** If calls are short, we can help more people.
*   **The Result:** Agents start hanging up on customers with difficult problems. They solve the easy ones and "accidentally" drop the hard ones to keep their average time down.
*   **Outcome:** Customers are furious.

**Attempt 2: The Right Metric**
*   **The Metric:** "First Call Resolution." (Did the customer call back within 24 hours?).
*   **The Logic:** If they don't call back, the problem is solved.
*   **The Result:** Agents stay on the line as long as it takes. They double-check everything.
*   **Outcome:** Call times go up, but customer satisfaction soars.

**The Application:**
This applies to any system.
*   Measuring **Lines of Code** creates bloated software.
*   Measuring **Hours Worked** often results in slower employees.
*   Measuring **Test Scores** produces students who are experts at taking tests, but not necessarily prepared for the open-ended problems of real life.

**The Rule:** You get what you measure, not what you want. Choose your metric carefully.
