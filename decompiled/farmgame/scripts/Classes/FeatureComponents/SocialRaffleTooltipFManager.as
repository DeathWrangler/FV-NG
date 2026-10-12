package Classes.FeatureComponents
{
   import Classes.FeatureBuilding;
   import Classes.SocialRaffle.SocialRaffleDataView;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Managers.SocialRaffleManager;
   
   public class SocialRaffleTooltipFManager extends FeatureManager implements ITooltipComponent
   {
      
      public function SocialRaffleTooltipFManager(owner:FeatureBuilding)
      {
         super(owner);
      }
      
      public function getTooltip() : String
      {
         var raffleEndTime:Number = NaN;
         var endTimeTip:String = null;
         var ticketCount:Number = NaN;
         var toolTip:String = "";
         var dataView:SocialRaffleDataView = SocialRaffleManager.getInstance().raffleDataView;
         if(dataView != null)
         {
            raffleEndTime = SocialRaffleManager.getInstance().raffleDataView.endTime;
            endTimeTip = FarmGameUtil.getTimeLeftText(raffleEndTime,"socialrafflebuilding_drawing_");
            if(raffleEndTime - GlobalEngine.serverTime / 1000 > 0)
            {
               toolTip += endTimeTip;
               toolTip += "\n";
            }
            ticketCount = dataView.getTotalNumTickets();
            if(ticketCount > 0)
            {
               toolTip += ZLocUtils.t("Dialogs","socialrafflebuilding_ticket_count",{
                  "ticketCount":ticketCount,
                  "ticket_word":ZLocUtils.tk("Dialogs","ticket_word","",ticketCount)
               });
            }
         }
         return toolTip;
      }
   }
}

