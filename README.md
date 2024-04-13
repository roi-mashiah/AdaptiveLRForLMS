# AdaptiveLRForLMS
The convergence of the LMS (Least Mean Squares) method and its dependency on the step size parameter are crucial considerations in various applications. In this work, we investigate the effects of step size on LMS convergence in a source coding scenario. An algorithm for adaptive learning rate is suggested and examined in various scenarios. The proposed algorithm is described here:

- Every predefined block size, calculate the MSE vector based on the error vector.
- If a previous value for the MSE exists, compare the current error to the previous.
- Decide the new step size according to the difference as follows:
  o If the difference is less than 𝐴 then we can increase the step size 𝜇, by 1+𝐺,0<𝐺<1 to converge faster, if 𝜇(1+𝐺)<𝜇𝑚𝑎𝑥
  o If the difference obeys 𝐴<𝑑<3𝐴, we are probably at some area close to a minimum which implies that we should decrease the current step size.
  o If 𝑑>3𝐴, we might be diverging so reduce the step size dramatically by a factor of 𝐺.
  o For any other case we stay with the previous step size
For more details reffer to the attached PDF.
