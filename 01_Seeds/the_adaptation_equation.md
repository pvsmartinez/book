# The Adaptation Equation

## The Formula
To understand how fast a system adapts (or "learns"), we can look at three variables:

$$ \text{Adaptation Speed} \approx \frac{\text{Iterations} \times \text{Mutation Rate}}{\text{Time}} $$

## The Variables
1.  **Iterations (Volume)**: How many "tries" do you get?
    *   *Bacteria*: Billions per hour.
    *   *Humans*: One generation every 25 years.
    *   *AI*: Millions of training runs per second.
2.  **Mutation Rate (Variance)**: How different is each try?
    *   *Low*: Safe, stable, slow change.
    *   *High*: Risky, many failures, but potential for massive leaps.
3.  **Time**: The constraint.

## The Learning Curve
*   **Viruses**: High Iteration + High Mutation = Instant Adaptation.
*   **Elephants**: Low Iteration + Low Mutation = Slow Adaptation (Vulnerable to rapid environmental change).
*   **Startups**: "Fail fast" is an attempt to artificially increase the Iteration rate to adapt to the market before running out of money (Time).

## The Trap: Over-Optimization (The Cheetah)
Adaptation has a blind spot. If the environment is too stable for too long, agents over-optimize for a single metric.
*   **The Cheetah:** Optimized purely for speed (Iteration on "Catch Prey").
*   **The Result:** It became so specialized (light, fast) that it lost the ability to defend itself.
*   **The Lesson:** Adaptation without changing constraints leads to fragility.
*   *See:* [[shifting_value_functions]]

## Conclusion
If you want to win against a system, you must either:
1.  Stop it from iterating.
2.  Change the environment faster than it can adapt.
