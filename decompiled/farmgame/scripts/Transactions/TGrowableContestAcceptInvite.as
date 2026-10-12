package Transactions
{
   import Classes.Growable.IGrowableResource;
   
   public class TGrowableContestAcceptInvite extends TCustomPlace
   {
      
      public function TGrowableContestAcceptInvite(growable:IGrowableResource)
      {
         super(growable.growableMapResource,false,0);
         m_params.isInvited = true;
      }
   }
}

