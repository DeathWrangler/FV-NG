package Widgets.Windows.Promotions
{
   import Classes.ZItem.HarvestableItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Managers.DreyersPromoManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Windows.FarmWindow;
   import flash.events.Event;
   import flash.text.TextFormat;
   
   public class DreyersWhatsThisDialog extends FarmWindow
   {
      
      private static const MAIN_TEXT_SIZE:Number = 16;
      
      public function DreyersWhatsThisDialog()
      {
         super(DreyersPromoManager.getWhatsThisAssetPath(),true,true);
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         var bars:HarvestableItem = null;
         var cost:int = 0;
         var sell:int = 0;
         var harvest:int = 0;
         var xp:int = 0;
         var bodyText:ZwTextField = null;
         var textFormat:TextFormat = null;
         var cropTitleText:ZwTextField = null;
         var costText:ZwTextField = null;
         var sellText:ZwTextField = null;
         var harvestText:ZwTextField = null;
         var xpText:ZwTextField = null;
         super.onLoadComplete(event);
         if(m_window)
         {
            bars = Global.farmGameSettingsManager.getFarmItemByName(DreyersPromoManager.DREYERS_FRUITBARS_ITEM_NAME) as HarvestableItem;
            cost = bars.cost;
            sell = bars.coinYield;
            harvest = bars.growTime * FarmGameUtil.NUM_HOURS_IN_DAY;
            xp = bars.plantXp;
            bodyText = new ZwTextField(m_window.body1_tf,DreyersPromoManager.getWhatIsThisLocalizedText(),true);
            textFormat = bodyText.getTextFormat();
            textFormat.size = MAIN_TEXT_SIZE;
            bodyText.setTextFormat(textFormat);
            addWidget(bodyText);
            cropTitleText = new ZwTextField(m_window.cropTitle_tf,DreyersPromoManager.getWhatIsThisLocalizedCropTitle(),true);
            addWidget(cropTitleText);
            m_window.cropTitle_tf.visible = true;
            costText = new ZwTextField(m_window.cost_tf,ZLocUtils.t("Dialogs","DreyersWhatIsThis_Cost",{"quantity":cost}),true);
            addWidget(costText);
            sellText = new ZwTextField(m_window.sell_tf,ZLocUtils.t("Dialogs","DreyersWhatIsThis_Sell",{"quantity":sell}),true);
            addWidget(sellText);
            harvestText = new ZwTextField(m_window.harvest_tf,ZLocUtils.t("Dialogs","DreyersWhatIsThis_Harvest",{"quantity":harvest}),true);
            addWidget(harvestText);
            xpText = new ZwTextField(m_window.xp_tf,ZLocUtils.t("Dialogs","DreyersWhatIsThis_Xp",{"quantity":xp}),true);
            addWidget(xpText);
            m_window.graphicSlot1_mc.visible = true;
            addWidget(new FarmAnimatedButton(m_window.accept_bt,onClose));
            DreyersPromoManager.countPromoDialogImpression();
         }
      }
   }
}

