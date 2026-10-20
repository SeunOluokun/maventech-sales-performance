-- Which sales team has the highest win rate?

select  t.manager as manager,
sum(case when p.deal_stage='Won' then 1 else 0 END) as total_won,
count(*) as closed_deals,
ROUND(100.0*sum(case when p.deal_stage='Won' then 1 else 0 END) /count(*),1) as team_win_rate
 from sales_teams t
inner join sales_pipeline p
on p.sales_agent = t.sales_agent
WHERE p.deal_stage IN ('Won', 'Lost')
group by manager
order by team_win_rate desc ;

/*
   Finding: team win rates range only from 62.1% to 64.4% (2.3 points),
   while individual agents range from 55% to 70% (see 02).
   Who works a deal matters more than which team they're on, so coaching
   should focus on individuals rather than team structure.
   Caveat: the top team (Cara Losch) closed the fewest deals (745 vs 1,418
   for Melvin Marxen), so a 0.1-point lead is not meaningful.
*/