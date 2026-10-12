package Widgets.Slots.Mastery
{
   import Cache.Classes.ZCacheUtil;
   import Classes.Mastery;
   import Classes.ZItem.HarvestableItem;
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.ProgressBars.FarmProgressBar;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.Mastery.MasteryWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class MasterySlot extends ZwSlotFrame
   {
      
      private static const SLOT_SIZE:Number = 50;
      
      protected static const SLOT_SIZE_V3:int = 92;
      
      protected static const SLOT_POST_REDUCTION:int = 75;
      
      protected var m_itemName:ZwTextField;
      
      protected var m_icon:FarmIcon;
      
      protected var m_signIcon:FarmIcon;
      
      protected var m_starsFrame:ZwFrame;
      
      protected var m_signFrame:ZwFrame;
      
      protected var m_progressBar:FarmProgressBar;
      
      protected var m_toolTip:FarmTextTooltip;
      
      protected var m_masteryWindow:MasteryWindow;
      
      public function MasterySlot(element:DisplayObject, masteryWindow:MasteryWindow)
      {
         super(element);
         this.m_masteryWindow = masteryWindow;
         if(m_element.backCard_mc)
         {
            addWidget(new ZwFrame(m_element.backCard_mc));
         }
         this.m_itemName = new ZwTextField(m_element.itemName_tf,"",true);
         addWidget(this.m_itemName);
         this.m_icon = new FarmIcon(m_element.icon_mc);
         if(this.m_masteryWindow.inVersion3())
         {
            this.m_icon.setIconSize(SLOT_SIZE_V3,SLOT_SIZE_V3);
         }
         else
         {
            this.m_icon.setIconHeight(SLOT_SIZE);
            this.m_icon.setIconWidth(SLOT_SIZE);
         }
         addWidget(this.m_icon);
         this.m_starsFrame = new ZwFrame(m_element.stars_mc);
         addWidget(this.m_starsFrame);
         this.m_progressBar = new FarmProgressBar(m_element.progressBar_mc);
         addWidget(this.m_progressBar);
         this.m_toolTip = new FarmTextTooltip();
         attachTooltip(this.m_toolTip);
         if(m_element.hasOwnProperty("sign_mc"))
         {
            this.m_signFrame = new ZwFrame(m_element.sign_mc);
            addWidget(this.m_signFrame,false);
            if(m_element.sign_mc.icon_0_mc)
            {
               this.m_signIcon = new FarmIcon(m_element.sign_mc.icon_0_mc);
               this.m_signIcon.setIconHeight(SLOT_POST_REDUCTION);
               this.m_signIcon.setIconWidth(SLOT_POST_REDUCTION);
               this.m_signFrame.addWidget(this.m_signIcon);
            }
         }
      }
      
      override public function populate(data:Object) : void
      {
         var mastery:Mastery = null;
         var curProgress:Number = NaN;
         var iconUrl:String = null;
         var totalNeeded:Number = NaN;
         super.populate(data);
         var harvestableItem:HarvestableItem = data as HarvestableItem;
         if(harvestableItem)
         {
            this.m_itemName.text = harvestableItem.friendlyTitle;
            this.m_itemName.visible = true;
            mastery = harvestableItem.mastery;
            curProgress = mastery.currentProgress;
            if(mastery.hasAllMasteries())
            {
               this.m_toolTip.setText(ZLocUtils.t("Dialogs","Mastered"));
               this.m_progressBar.progress = 100;
            }
            else
            {
               totalNeeded = mastery.totalCropsNeeded;
               this.m_progressBar.progress = curProgress / totalNeeded * 100;
               this.m_toolTip.setText(ZLocUtils.t("Dialogs","MasteryProgress",{
                  "quantity":curProgress,
                  "quantityTotal":totalNeeded
               }));
            }
            iconUrl = harvestableItem.masteryIconUrl();
            if(iconUrl == null)
            {
               iconUrl = harvestableItem.icon;
            }
            if(Boolean(mastery.hasAllMasteries()) && Boolean(this.m_signIcon) && Global.player.masterySignCleaned)
            {
               this.m_signIcon.loadIcon(iconUrl);
               this.m_signIcon.visible = true;
               this.m_signFrame.visible = true;
            }
            else
            {
               this.m_icon.loadIcon(iconUrl);
               this.m_icon.visible = true;
            }
            (m_element.stars_mc as MovieClip).gotoAndStop(mastery.currentLevel + 2);
            this.m_starsFrame.visible = true;
            this.m_progressBar.visible = true;
            if(m_element.backCard_mc)
            {
               getWidget(m_element.backCard_mc).visible = true;
            }
            if(this.m_masteryWindow.inVersion3())
            {
               this.setupMasterySignPurchaseFrame(data);
            }
         }
      }
      
      protected function setupMasterySignPurchaseFrame(data:Object) : void
      {
         var code:String = this.getMasterySignCode(data);
         if(Boolean(code) && Boolean(Global.player.masterySignEnabled()) && this.canPurchase(code))
         {
            removeWidget(m_element.buyBack_mc.buy_bt);
            addWidget(new FarmAnimatedTextButton(m_element.buyBack_mc.buy_bt,ZLocUtils.t("Dialogs","Mastery_BuyBackBtn"),ZCacheUtil.applyPartial(this.purchaseMasterySign,this,[code,this.getType(data),this.getItemId(data)])));
            m_element.buyBack_mc.buy_bt.coin_tf.text = this.m_masteryWindow.masterySignCoinCost().toString();
            removeWidget(m_element.buyBack_mc.buyBack_tf);
            addWidget(new ZwTextField(m_element.buyBack_mc.buyBack_tf,ZLocUtils.t("Dialogs","Mastery_BuyBack")));
            m_element.buyBack_mc.visible = true;
            m_element.buyBack_mc.buy_bt.visible = true;
            m_element.buyBack_mc.buy_bt.coin_tf.visible = true;
            m_element.buyBack_mc.buyBack_tf.visible = true;
         }
         else
         {
            m_element.buyBack_mc.visible = false;
         }
      }
      
      protected function getItemId(data:Object) : String
      {
         var result:String = "";
         var harvestableItem:HarvestableItem = data as HarvestableItem;
         if(harvestableItem)
         {
            result = harvestableItem.name;
         }
         return result;
      }
      
      protected function getType(data:Object) : String
      {
         var result:String = "";
         var harvestableItem:HarvestableItem = data as HarvestableItem;
         if(harvestableItem)
         {
            result = harvestableItem.type;
         }
         return result;
      }
      
      private function purchaseMasterySign(code:String, item:String, type:String, event:Event) : void
      {
         if(this.m_masteryWindow)
         {
            this.m_masteryWindow.purchaseMasterySign(code,item,type);
         }
      }
      
      override public function release() : void
      {
         super.release();
         this.m_itemName = null;
         this.m_icon = null;
         this.m_starsFrame = null;
         this.m_progressBar = null;
         this.m_toolTip = null;
         this.m_masteryWindow = null;
      }
      
      protected function getMasterySignCode(data:Object) : String
      {
         var result:String = "";
         var harvestableItem:HarvestableItem = data as HarvestableItem;
         if(harvestableItem.hasMastery && Boolean(harvestableItem.mastery.finalGift))
         {
            result = Global.farmGameSettingsManager.getFarmItemCodeByName(harvestableItem.mastery.finalGift);
         }
         return result;
      }
      
      protected function canPurchase(masterySignCode:String) : Boolean
      {
         return this.m_masteryWindow.inBuyBackExperiment() && this.m_masteryWindow.getPurchasableSigns().indexOf(masterySignCode) != -1;
      }
   }
}

