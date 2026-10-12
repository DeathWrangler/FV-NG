package Widgets.Slots.FishingDerby
{
   import Classes.Collections.FishingCollectible;
   import Classes.util.ZLocUtils;
   import Managers.FeatureOptionsManager;
   import Managers.FishingDerbyManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FishingDerby.FishingDerbyCollectionFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.ProgressBars.FarmProgressBar;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.FishingDerby.FishingDerbyCollectionWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import gs.TweenLite;
   
   public class FishingDerbyCollectionSlot extends ZwSlotFrame
   {
      
      private static const ICON_SIZE:int = 100;
      
      private var m_collectibleName:ZwTextField;
      
      private var m_masteryFrame:ZwFrame;
      
      private var m_icon:FarmIcon;
      
      private var m_parentFrame:FishingDerbyCollectionFrame;
      
      private var m_masteryProgressBar:FarmProgressBar;
      
      private var m_masteryStars:ZwFrame;
      
      private var m_questionMark:FarmButton;
      
      private var m_counter:ZwTextField;
      
      private var m_masteryPurchaseBtn:FarmAnimatedCashButton;
      
      private var m_masteryCompleteTf:FarmTextField;
      
      private var m_collectible:FishingCollectible;
      
      public function FishingDerbyCollectionSlot(element:DisplayObject, parentFrame:FishingDerbyCollectionFrame)
      {
         this.m_parentFrame = parentFrame;
         super(element);
         addWidget(this.m_collectibleName = new ZwTextField(m_element.itemTitle_tf));
         addWidget(this.m_icon = new FarmIcon(m_element.item_mc));
         this.m_icon.setIconSize(ICON_SIZE,ICON_SIZE);
         addWidget(this.m_masteryFrame = new ZwFrame(m_element.mastery_mc));
         this.m_masteryFrame.addWidget(this.m_masteryProgressBar = new FarmProgressBar(m_element.mastery_mc.masteryInfo));
         this.m_masteryFrame.addWidget(this.m_masteryStars = new ZwFrame(m_element.mastery_mc.stars_mc));
         addWidget(this.m_questionMark = new FarmButton(m_element.question_bt));
         addWidget(this.m_counter = new ZwTextField(m_element.itemAmount_tf));
         addWidget(this.m_masteryPurchaseBtn = new FarmAnimatedCashButton(m_element.buy_bt,ZLocUtils.t("Dialogs","FishingDerby_buyMastery_btn"),"",this.onPurchaseMastery));
         if(m_element["checkmark_mc"])
         {
            (m_element.checkmark_mc as MovieClip).visible = false;
         }
         addWidget(this.m_masteryCompleteTf = new FarmTextField(m_element.mastery_tf,ZLocUtils.t("Dialogs","FishingDerby_mastery_complete")),false);
      }
      
      override public function populate(data:Object) : void
      {
         var description:String = null;
         var collectionMastery:Object = null;
         var masteryData:Object = null;
         var currentMasteryCount:int = 0;
         var price:int = 0;
         var bootCollectionUnlocked:Boolean = false;
         super.populate(data);
         this.m_collectible = data as FishingCollectible;
         if(this.m_collectible != null)
         {
            this.m_collectibleName.text = ZLocUtils.tk_pk_asTitle("Items:" + this.m_collectible.name + "_friendlyName");
            this.m_collectibleName.visible = true;
            (this.m_masteryFrame.element as MovieClip).gotoAndStop(0);
            this.m_masteryFrame.visible = true;
            this.m_icon.loadIcon(this.m_collectible.assetPath);
            this.m_icon.visible = true;
            this.m_icon.alpha = 1;
            description = ZLocUtils.t_pk("Items",this.m_collectible.name + "_message");
            if(description != null)
            {
               this.m_questionMark.visible = true;
               this.m_questionMark.detachTooltip();
               this.m_questionMark.attachTooltip(new FarmTextTooltip(description));
            }
            collectionMastery = this.m_parentFrame.masteryData.hasOwnProperty(this.m_parentFrame.collection.name) ? this.m_parentFrame.masteryData[this.m_parentFrame.collection.name] : new Object();
            masteryData = FishingDerbyManager.getMasteryDataObject(collectionMastery,this.m_collectible);
            if(masteryData.currentLevel == 3)
            {
               this.m_masteryProgressBar.progress = 100;
               this.m_masteryPurchaseBtn.visible = false;
               this.m_masteryCompleteTf.visible = true;
            }
            else
            {
               this.m_masteryProgressBar.progress = masteryData.currentProgress / masteryData.totCountRequired * 100;
               this.m_masteryPurchaseBtn.visible = true;
               price = FishingDerbyManager.instance.calculateCostForMastery(this.m_collectible.rarity);
               this.m_masteryPurchaseBtn.setAmountText(price.toString());
               this.m_masteryCompleteTf.visible = false;
               if(this.m_collectible.collectionName === "fishing_boot")
               {
                  bootCollectionUnlocked = Boolean(FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.FISHING_DERBY,FeatureOptionsManager.FEATURE_BOOT));
                  this.m_masteryPurchaseBtn.visible = bootCollectionUnlocked;
                  this.m_masteryCompleteTf.text = ZLocUtils.t("Dialogs","FishingDerby_mastery_locked");
               }
            }
            (this.m_masteryStars.element as MovieClip).gotoAndStop(masteryData.currentLevel + 1);
            currentMasteryCount = collectionMastery.hasOwnProperty(this.m_collectible.name) ? int(collectionMastery[this.m_collectible.name]) : 0;
            if(currentMasteryCount > 0)
            {
               this.m_icon.applyGrayOut = false;
               this.m_counter.visible = true;
               this.m_counter.text = "x" + currentMasteryCount;
            }
            else
            {
               this.m_icon.alpha = 0.6;
               this.m_icon.applyGrayOut = true;
               this.m_counter.visible = false;
            }
         }
      }
      
      private function onPurchaseMastery(event:Event) : void
      {
         var window:FishingDerbyCollectionWindow = null;
         window = this.m_parentFrame.parent as FishingDerbyCollectionWindow;
         if(window)
         {
            window.enableInput = false;
            window.tintWindow();
         }
         FishingDerbyManager.instance.purchaseMasteryForCollectible(this.m_parentFrame.collection.name,this.m_collectible,this.onPurchaseConfirmation);
      }
      
      private function onPurchaseConfirmation(purchased:Boolean) : void
      {
         var window:FishingDerbyCollectionWindow = null;
         window = this.m_parentFrame.parent as FishingDerbyCollectionWindow;
         if(purchased)
         {
            if(m_element["checkmark_mc"])
            {
               (m_element.checkmark_mc as MovieClip).visible = true;
               (m_element.checkmark_mc as MovieClip).alpha = 1;
               TweenLite.to(m_element.checkmark_mc,1.5,{"alpha":0});
            }
            if(window)
            {
               window.setActiveCollection(this.m_parentFrame.collection);
               this.populate(this.m_collectible);
            }
         }
         if(window)
         {
            window.enableInput = true;
            window.untintWindow();
         }
      }
      
      override public function release() : void
      {
         this.m_collectibleName = null;
         this.m_masteryFrame = null;
         this.m_icon = null;
         this.m_parentFrame = null;
         this.m_masteryProgressBar = null;
         this.m_masteryStars = null;
         this.m_questionMark = null;
         this.m_counter = null;
         this.m_masteryPurchaseBtn = null;
         this.m_collectible = null;
         this.m_masteryCompleteTf = null;
         super.release();
      }
   }
}

