package Widgets.Frames.Market
{
   import Classes.util.ZLocUtils;
   import Managers.MarketFlashSaleManager;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.TextFields.CountdownTimeTextField;
   import flash.display.MovieClip;
   
   public class MarketFlashSaleFrame extends ZwFrame
   {
      
      public function MarketFlashSaleFrame(element:MovieClip)
      {
         super(element);
         if(element)
         {
            addWidget(new ZwTextField(element.title_tf,ZLocUtils.t("Dialogs","MarketSale_title",{"off":MarketFlashSaleManager.instance.getSaleOffPercentage()})));
            addWidget(new ZwTextField(element.body_tf,ZLocUtils.t("Dialogs","MarketSale_body",{"minFC":MarketFlashSaleManager.instance.getSaleMinAffectedItemCost() - 1})));
            addWidget(new ZwTextField(element.timer_tf,ZLocUtils.t("Dialogs","MarketSale_timer")));
            addWidget(new CountdownTimeTextField(element.value_0_tf,MarketFlashSaleManager.instance.getTimeLeft,MarketFlashSaleManager.instance.conditionallyDisableSaleUI,true));
         }
      }
   }
}

