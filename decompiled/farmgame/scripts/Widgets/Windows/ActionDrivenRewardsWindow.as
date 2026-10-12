package Widgets.Windows
{
   import Classes.Constants.StatsTrackingConstants;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.ActionDrivenManager;
   import Managers.FeatureOptionsManager;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Frames.ActionDrivenRewardsSlotContainerFrame;
   import Widgets.TextFields.FarmTextField;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   
   public class ActionDrivenRewardsWindow extends FarmWindow
   {
      
      public static const NUM_REVEALED_THRESHOLD:int = 5;
      
      private static var totalItems:int = 0;
      
      private var m_featureName:String;
      
      private var m_numRevealed:int;
      
      private var m_loadingWidget:ZwWidget;
      
      private var m_subTitleTextField:FarmTextField;
      
      private var m_genericTextField:FarmTextField;
      
      private var m_rewardCountFrame:ZwFrame;
      
      private var m_rewardCountTextField:FarmTextField;
      
      private var m_rewards:Object = null;
      
      private var m_slots:ActionDrivenRewardsSlotContainerFrame;
      
      private var m_acceptButton:FarmAnimatedButton;
      
      private var m_acceptButtonClicked:Boolean;
      
      private var m_className:String;
      
      private var m_manager:ActionDrivenManager;
      
      private var m_disclaimerLink:ZwButton;
      
      private var m_isDisplayFlag:Boolean = true;
      
      public function ActionDrivenRewardsWindow(featureName:String)
      {
         this.m_manager = ActionDrivenManager.getInstance(featureName);
         super(this.m_manager.getConstantsStringWithKey("endAssetPath"));
         this.m_featureName = featureName;
         this.m_className = "ActionDrivenRewardsWindow";
      }
      
      public static function show(featureName:String) : void
      {
         if(featureName)
         {
            UI.displayPopup(new ActionDrivenRewardsWindow(featureName),true,featureName + "Rewards",true);
         }
      }
      
      public static function grant(featureName:String) : void
      {
         var actionDrivenRewardsObject:ActionDrivenRewardsWindow = null;
         if(featureName)
         {
            actionDrivenRewardsObject = new ActionDrivenRewardsWindow(featureName);
            actionDrivenRewardsObject.IsDisplayFlag = false;
            actionDrivenRewardsObject.GrantRewardsPostFeatureExpiry(featureName);
         }
      }
      
      public function set IsDisplayFlag(value:Boolean) : void
      {
         this.m_isDisplayFlag = value;
      }
      
      override protected function postLoadComplete() : void
      {
         var subtitle:String = null;
         super.postLoadComplete();
         this.m_manager.grantExtraReward();
         if(m_window)
         {
            if(m_window.loading_mc)
            {
               this.m_loadingWidget = new ZwWidget(m_window.loading_mc);
               addWidget(this.m_loadingWidget,false);
            }
            if(m_window.title_tf)
            {
               addWidget(new FarmTextField(m_window.title_tf,"Congratulations!"));
            }
            if(m_window.subtitle_tf)
            {
               subtitle = "OPEN ALL PRESENTS";
               this.m_subTitleTextField = new FarmTextField(m_window.subtitle_tf);
               addWidget(this.m_subTitleTextField);
            }
            if(m_window.generic_tf)
            {
               this.m_genericTextField = new FarmTextField(m_window.generic_tf,this.m_manager.getString(this.m_className + "_giftbox"));
               addWidget(this.m_genericTextField);
            }
            if(m_window.count_mc)
            {
               this.m_rewardCountFrame = new ZwFrame(m_window.count_mc);
               addWidget(this.m_rewardCountFrame,false);
            }
            if(m_window.count_mc)
            {
               if(m_window.count_mc.youhave_tf)
               {
                  this.m_rewardCountFrame.addWidget(new FarmTextField(m_window.count_mc.youhave_tf,this.m_manager.getString(this.m_className + "_youHave")));
               }
               if(m_window.count_mc.giftcount_tf)
               {
                  this.m_rewardCountTextField = new FarmTextField(m_window.count_mc.giftcount_tf);
                  this.m_rewardCountFrame.addWidget(this.m_rewardCountTextField);
               }
               if(m_window.count_mc.gifts_tf)
               {
                  this.m_rewardCountFrame.addWidget(new FarmTextField(m_window.count_mc.gifts_tf,this.m_manager.getString(this.m_className + "_gifts")));
               }
            }
            if(m_window.slots_mc)
            {
               this.m_slots = new ActionDrivenRewardsSlotContainerFrame(m_window.slots_mc);
               addWidget(this.m_slots,false);
            }
            if(m_window.accept_bt)
            {
               this.m_acceptButton = new FarmAnimatedTextButton(m_window.accept_bt,this.m_manager.getString(this.m_className + "_openAll"),this.onAcceptButtonClick);
               addWidget(this.m_acceptButton,false);
            }
            if(m_window.hasOwnProperty("disclaimer_tf"))
            {
               this.m_disclaimerLink = addWidget(new ZwButton(m_window.disclaimer_tf,this.onDisclaimerLinkClick)) as ZwButton;
               this.m_disclaimerLink.element.useHandCursor = true;
               this.m_disclaimerLink.element.buttonMode = true;
               this.m_disclaimerLink.element.mouseChildren = false;
            }
            this.refresh(true);
         }
         this.count(StatsTrackingConstants.IMPRESSIONS);
      }
      
      override protected function release() : void
      {
         this.m_featureName = null;
         this.m_loadingWidget = null;
         this.m_subTitleTextField = null;
         this.m_genericTextField = null;
         this.m_rewardCountFrame = null;
         this.m_rewardCountTextField = null;
         this.m_slots = null;
         this.m_acceptButton = null;
         super.release();
      }
      
      public function GrantRewardsPostFeatureExpiry(featureName:String) : void
      {
         this.m_manager.grantExtraReward();
         var rewards:Object = FeatureOptionsManager.getInstance().getFeatureOption(featureName,"allItems") as Object;
         if(!rewards)
         {
            TransactionManager.addTransaction(new TGenericTransaction(ActionDrivenWindow.SERVICE_CLASS,"generateRewards",this.onGenerateRewardsResult,[this.m_featureName]),true);
         }
         this.close();
      }
      
      private function onDisclaimerLinkClick(event:Event) : void
      {
         navigateToURL(new URLRequest("http://zynga.org/campaigns/farmville-donorschoose"),"_blank");
      }
      
      private function getMaxActionCount() : int
      {
         return this.m_manager.getConstantsIntWithKey("maxActionCount");
      }
      
      public function refresh(firstRefresh:Boolean = false) : void
      {
         var slotItems:Array = null;
         var itemName:String = null;
         var rewardCount:int = 0;
         var isReward:Boolean = false;
         var numRewards:int = 0;
         var rewards:Object = FeatureOptionsManager.getInstance().getFeatureOption(this.m_featureName,"allItems") as Object;
         if(rewards)
         {
            this.hideLoadingWidget();
            totalItems = 0;
            if(this.m_slots)
            {
               slotItems = [];
               for(itemName in rewards)
               {
                  totalItems += rewards[itemName];
                  rewardCount = parseInt(rewards[itemName]);
                  isReward = rewardCount == 0 ? false : true;
                  if(isReward)
                  {
                     slotItems.unshift({
                        "name":itemName,
                        "count":rewardCount,
                        "revealed":true,
                        "isReward":true,
                        "featureName":this.m_featureName
                     });
                  }
               }
               this.m_slots.items = slotItems;
               this.m_slots.visible = true;
            }
            if(this.m_rewardCountTextField)
            {
               numRewards = FeatureOptionsManager.getInstance().getFeatureOption(this.m_featureName,"rewardCount") as int;
               this.m_rewardCountTextField.text = String(numRewards) + "/" + this.getMaxActionCount();
            }
            if(this.m_rewardCountFrame)
            {
               this.m_rewardCountFrame.visible = true;
            }
            if(Boolean(this.m_subTitleTextField) && firstRefresh)
            {
               this.m_subTitleTextField.visible = false;
            }
            if(Boolean(m_window) && Boolean(m_window.giftfireworks_mc))
            {
               m_window.giftfireworks_mc.visible = true;
               m_window.giftfireworks_mc.gotoAndPlay(2);
            }
         }
         else
         {
            this.showLoadingWidget();
            TransactionManager.addTransaction(new TGenericTransaction(ActionDrivenWindow.SERVICE_CLASS,"generateRewards",this.onGenerateRewardsResult,[this.m_featureName]),true);
         }
      }
      
      public function updateRewardCounter(numRewards:int) : void
      {
         if(this.m_rewardCountTextField)
         {
            this.m_rewardCountTextField.text = String(numRewards) + "/" + this.getMaxActionCount();
         }
      }
      
      public function incrementNumRevealed() : void
      {
         ++this.m_numRevealed;
         this.m_acceptButton.visible = this.m_numRevealed >= NUM_REVEALED_THRESHOLD && this.m_numRevealed < this.m_slots.slotData.length && !this.m_acceptButtonClicked;
      }
      
      private function onGenerateRewardsResult(result:Object) : void
      {
         var rewards:Object = null;
         var totalRewards:int = 0;
         var rewardName:String = null;
         var rewardCount:int = 0;
         if(result.hasOwnProperty("allItems"))
         {
            rewards = result["allItems"] is Object ? result["allItems"] : new Object();
            totalRewards = 0;
            this.m_rewards = rewards;
            for(rewardName in rewards)
            {
               rewardCount = parseInt(rewards[rewardName]);
               if(rewardCount > 0)
               {
                  totalRewards += rewardCount;
                  Global.player.addGift(rewardName,"0",rewardCount);
               }
            }
            FeatureOptionsManager.getInstance().setFeatureOption(this.m_featureName,"allItems",result["allItems"]);
            if(result.hasOwnProperty("rewardCount"))
            {
               FeatureOptionsManager.getInstance().setFeatureOption(this.m_featureName,"rewardCount",result["rewardCount"]);
            }
            if(this.m_isDisplayFlag)
            {
               this.refresh();
            }
            this.count(totalRewards.toString());
         }
      }
      
      private function showLoadingWidget() : void
      {
         var element:MovieClip = null;
         var i:int = 0;
         var child:MovieClip = null;
         if(Boolean(this.m_loadingWidget) && Boolean(this.m_loadingWidget.element))
         {
            this.m_loadingWidget.visible = true;
            element = this.m_loadingWidget.element as MovieClip;
            for(i = 0; i < element.numChildren; i++)
            {
               child = element.getChildAt(i) as MovieClip;
               if(child)
               {
                  child.gotoAndPlay(1);
               }
            }
         }
      }
      
      private function hideLoadingWidget() : void
      {
         var element:MovieClip = null;
         var i:int = 0;
         var child:MovieClip = null;
         if(Boolean(this.m_loadingWidget) && Boolean(this.m_loadingWidget.element))
         {
            this.m_loadingWidget.visible = false;
            element = this.m_loadingWidget.element as MovieClip;
            for(i = 0; i < element.numChildren; i++)
            {
               child = element.getChildAt(i) as MovieClip;
               if(child)
               {
                  child.stop();
               }
            }
         }
      }
      
      private function onAcceptButtonClick(event:Event) : void
      {
         this.m_acceptButtonClicked = true;
         this.m_acceptButton.visible = false;
         this.m_slots.revealAll();
         this.m_numRevealed = this.m_slots.slotData.length;
         this.count("open_all");
      }
      
      private function onCloseConfirmationClosed(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            Global.player.setSeenFlag(this.m_className + this.m_featureName);
            this.close();
         }
      }
      
      override public function close() : void
      {
         super.close();
         this.count(StatsTrackingConstants.CLOSE);
      }
      
      private function count(phylum:String) : void
      {
         StatsManager.count(this.m_featureName,this.m_className,phylum);
      }
   }
}

