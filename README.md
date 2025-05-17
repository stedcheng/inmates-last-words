<h1>Rage, Regret, and Repentance: A Psycho-linguistic Analysis of Inmates' Last Statements</h1>

<h2>Abstract</h2>
<h3>Introduction and Literature Review</h3>
Psycholinguistic analyses assert that the expression of final statements is a form of control that responds to speakers' extreme circumstances. The Terror Management Theory allows the convicted a final chance of showing agency and elevating self-esteem. However, this framework does not describe the range of their reactions and does not explain the negative emotions felt by some convicted. On the other hand, the study of last words can focus on its performative or ritualistic aspects. For example, playful and humorous language may be used to cope with and subvert the pending execution, ultimately letting the convicted present themselves as the protagonists. Last words can also reflect how the convicted makes meaning of their execution, which is already known in advance. The juxtaposition between this knowledge and the temporary "freedom" may alter the meaning-making process, which can cause them to realize their wrongdoings and ask for forgiveness.

<h3>Methods</h3>
The Texas State Department of Criminal Justice (TDCJ) compiles the last words spoken by death row inmates since 1982. Demographic information such as age, ethnicity, and education were collected, leading to a total of 591 inmates, though only 470 provided last statements. These last words will be inductively analyzed through topic modeling using Latent Dirichlet Allocation, an unsupervised machine learning algorithm. Then, word frequencies per cluster will be tabulated, compared against the other clusters, and tied together by a narrative. Lastly, the race and education level of the inmates will be used in the clustering procedure to discover patterns between demographics and final statements.

<h3>Results</h3>
The final statements have many positive words and are portrayed as a conversation instead of a monologue, showing that they play both terror management and dramaturgical perspectives. The presence of the word "warden" asserts the performative nature of the speech. Using a perplexity plot, five clusters were chosen, namely, rage, resignation, regret, religion, and resistance. Three major races were identified: white, black, and Hispanic. Two unique themes include how blacks recognized their remaining time and mentioned how their race could have been a factor in the execution, and how Hispanics tend to ask for forgiveness directly to the families of the victims. Moreover, three educational levels were identified as well: low (8 or fewer years of education, medium (from 9 to 11 years), and high (12 or more years). However, word usage was shown to be similar regardless of education level, which may be because of the long and arduous time in the death row and the emotional intensity during the execution day.

<h3>Conclusion</h3>
When analyzing convicts, they are usually viewed as detached from their context and experiences in prison. By utilizing an inductive approach, human judgment is supplemented by the themes extracted through topic modeling. Through analyzing the variation across races, it was revealed that their last words not only have different dominant themes but are also expressed differently. For future work, the relationship between inmates' death row statements and other features such as geography, generation, marital status, family background, or trial process (length, presence of a private attorney) can be analyzed.

<h2>Files</h2>
<ul>
  <li><code>Report.pdf</code>: Main text of the report.</li>
  <li><code>Appendix.pdf</code>: Contains the references and sample texts.</li>
  <li><code>Slide Deck.pdf</code>: Slide deck used to present the research.</li>
  <li><code>cluster_texas.R</code>: Codes used to generate clusters and top words for the entire dataset.</li>
  <li><code>cluster_race.R</code>: Codes used to generate clusters and top words for each race.</li>
  <li><code>cluster_education.R</code>: Codes used to generate clusters and top words for each education level.</li>
  <li><code>Texas Inmates 2024.csv</code>: Dataset of inmates' last words, retrieved from <a href="https://www.tdcj.texas.gov/death_row/dr_executed_offenders.html">TDCJ</a> and <a href="https://www.kaggle.com/datasets/mykhe1097/last-words-of-death-row-inmates/data">Kaggle</a> </ul>

<h2>Credits</h2>
This project was created by Aldie Alejandro, Sted Cheng, and Robert Leung, and submitted as a requirement for the course <b>PSYC 80.18i: Data Analytics for Text Analysis</b> taken in the first semester of AY 2024-2025 in Ateneo de Manila University. 


