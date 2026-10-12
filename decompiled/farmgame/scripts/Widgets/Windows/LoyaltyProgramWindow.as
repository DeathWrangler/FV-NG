package Widgets.Windows
{
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Managers.LoyaltyProgramManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Constants.Market.Currency;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.events.Event;
   
   public class LoyaltyProgramWindow extends FarmWindow
   {
      
      private var m_MoreInfo:ZwWidget = null;
      
      public function LoyaltyProgramWindow()
      {
         super("assets/dialogs/FV_LoyaltyProgram2013.swf");
      }
      
      override protected function postLoadComplete() : void
      {
         var timeElapsed:Number = NaN;
         var timeLeft:String = null;
         var statusPoints:int = 0;
         var pointsText:String = null;
         var earnText:String = null;
         var nextMonth:String = null;
         var startDate:String = null;
         var neededText:String = null;
         var qualifyDate:String = null;
         var neededAmount:String = null;
         var activeText:String = null;
         super.postLoadComplete();
         var isGoldenFarmer:Boolean = LoyaltyProgramManager.getInstance().isGoldenFarmer();
         if(m_window.title_tf)
         {
            addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs","LoyaltyWindow_title")));
         }
         if(m_window.timer_tf)
         {
            timeElapsed = LoyaltyProgramManager.getEndOfThisMonthTime() - new Date(GlobalEngine.serverTime).time / 1000;
            timeLeft = FarmGameUtil.toFriendlyTime(timeElapsed,true);
            addWidget(new ZwTextField(m_window.timer_tf,timeLeft + " left!"),!isGoldenFarmer);
         }
         var currentPoints:Number = LoyaltyProgramManager.getInstance().getPointsForTheMonth();
         var goldenThreshold:Number = LoyaltyProgramManager.getInstance().goldenFarmerThreshold();
         if(m_window.tutorial_mc)
         {
            addWidget(this.m_MoreInfo = new ZwWidget(m_window.tutorial_mc),false);
            if(m_window.tutorial_mc.close2_bt)
            {
               addWidget(new FarmButton(m_window.tutorial_mc.close2_bt,this.closeTutorial));
            }
            if(m_window.tutorial_mc.header_tf)
            {
               addWidget(new ZwTextField(m_window.tutorial_mc.header_tf,ZLocUtils.t("Dialogs","LoyaltyWindow_tuttitle")));
            }
            if(m_window.tutorial_mc.description2_tf)
            {
               addWidget(new ZwTextField(m_window.tutorial_mc.description2_tf,ZLocUtils.t("Dialogs","LoyaltyWindow_descriptionTwo",{"goldenThreshold":goldenThreshold})));
            }
            if(m_window.tutorial_mc.link_mc)
            {
               addWidget(new ZwWidget(m_window.tutorial_mc.link_mc));
               if(m_window.tutorial_mc.link_mc.link_tf)
               {
                  addWidget(new ZwTextField(m_window.tutorial_mc.link_mc.link_tf,ZLocUtils.t("Dialogs","LoyaltyWindow_moreDetails")));
               }
            }
         }
         if(m_window.whatisthis_mc)
         {
            addWidget(new FarmAnimatedButton(m_window.whatisthis_mc,this.showMoreInfo));
         }
         if(m_window.redeem_mc)
         {
            addWidget(new ZwWidget(m_window.redeem_mc));
            if(m_window.redeem_mc.have_tf)
            {
               addWidget(new ZwTextField(m_window.redeem_mc.have_tf,ZLocUtils.t("Dialogs","LoyaltyWindow_youHave")));
            }
            if(m_window.redeem_mc.count_tf)
            {
               statusPoints = Global.player.getWorldCurrencyTotal(Currency.COST_STATUS_POINTS);
               addWidget(new ZwTextField(m_window.redeem_mc.count_tf,statusPoints.toString()));
            }
            if(m_window.redeem_mc.generic_tf)
            {
               addWidget(new ZwTextField(m_window.redeem_mc.generic_tf,ZLocUtils.t("Dialogs","LoyaltyWindow_points")));
            }
            if(m_window.redeem_mc.redeem_bt)
            {
               addWidget(new FarmAnimatedButton(m_window.redeem_mc.redeem_bt,this.redeemStatusPoints));
            }
         }
         if(m_window.points_tf)
         {
            pointsText = isGoldenFarmer ? ZLocUtils.t("Dialogs","LoyaltyWindow_pointsYay") : currentPoints + " earned";
            addWidget(new ZwTextField(m_window.points_tf,pointsText));
         }
         if(m_window.buy2_bt)
         {
            addWidget(new FarmAnimatedCashButton(m_window.buy2_bt,"Buy",LoyaltyProgramManager.getInstance().goldenFarmerCost().toString(),this.buyGoldenFarmerStatus),!isGoldenFarmer);
         }
         if(m_window.earn_tf)
         {
            earnText = "";
            if(!isGoldenFarmer)
            {
               earnText = ZLocUtils.t("Dialogs","LoyaltyWindow_earnText");
            }
            else
            {
               nextMonth = LoyaltyProgramManager.endOfMonthAfterCurrentMonth();
               startDate = LoyaltyProgramManager.startOfMonthAfterCurrentMonth();
               earnText = ZLocUtils.t("Dialogs","LoyaltyWindow_earnTextTwo",{
                  "nextMonth":nextMonth,
                  "startDate":startDate
               });
            }
            addWidget(new ZwTextField(m_window.earn_tf,earnText));
         }
         if(m_window.needed_tf)
         {
            neededText = "";
            qualifyDate = "";
            if(!isGoldenFarmer)
            {
               qualifyDate = LoyaltyProgramManager.endOfNextMonthReadableDate();
               neededAmount = (goldenThreshold - currentPoints).toString();
               neededText = ZLocUtils.t("Dialogs","LoyaltyWindow_neededText",{
                  "neededAmount":neededAmount,
                  "qualifyDate":qualifyDate
               });
            }
            else
            {
               qualifyDate = LoyaltyProgramManager.getInstance().goldenFarmerExpirationReadableDate();
               neededText = ZLocUtils.t("Dialogs","LoyaltyWindow_neededText2",{"qualifyDate":qualifyDate});
            }
            addWidget(new ZwTextField(m_window.needed_tf,neededText));
         }
         if(m_window.description_tf)
         {
            addWidget(new ZwTextField(m_window.description_tf,ZLocUtils.t("Dialogs","LoyaltyWindow_description")));
         }
         if(m_window.status_mc)
         {
            addWidget(new ZwWidget(m_window.status_mc));
            if(m_window.status_mc.generic2_tf)
            {
               addWidget(new ZwTextField(m_window.status_mc.generic2_tf,ZLocUtils.t("Dialogs","LoyaltyWindow_generic")));
            }
            if(m_window.status_mc.count2_tf)
            {
               activeText = LoyaltyProgramManager.getInstance().getGoldenFarmerStatusText();
               addWidget(new ZwTextField(m_window.status_mc.count2_tf,activeText));
            }
         }
      }
      
      private function closeTutorial(event:Event) : void
      {
         if(this.m_MoreInfo)
         {
            this.m_MoreInfo.visible = false;
         }
      }
      
      private function showMoreInfo(event:Event) : void
      {
         if(this.m_MoreInfo)
         {
            this.m_MoreInfo.visible = true;
         }
      }
      
      private function buyGoldenFarmerStatus(event:Event) : void
      {
         close();
         LoyaltyProgramManager.getInstance().buyGoldenFarmerStatus();
      }
      
      private function redeemStatusPoints(event:Event) : void
      {
         close();
         LoyaltyProgramManager.redeemStatusPoints();
      }
   }
}

