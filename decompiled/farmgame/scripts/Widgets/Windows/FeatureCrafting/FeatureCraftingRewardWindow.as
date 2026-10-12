package Widgets.Windows.FeatureCrafting
{
   import Classes.Constants.ZLocConstants;
   import Classes.FeatureCrafting.FeatureCraftingInventoryPart;
   import Classes.FeatureCrafting.FeatureCraftingOrderBoard;
   import Classes.FeatureCrafting.FeatureCraftingSystem;
   import Classes.ImageLoader;
   import Classes.ZItem.FarmItem;
   import Classes.util.FacebookSocialNetwork;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Managers.FeatureCraftingManager;
   import Managers.JMInnovationManager;
   import Managers.TemplateUIUtility;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class FeatureCraftingRewardWindow extends FarmWindow
   {
      
      private static const ICON_SIZE:int = 100;
      
      private var m_orderBoard:FeatureCraftingOrderBoard;
      
      private var m_orderBoardTimestamp:Number;
      
      private var m_dialogBackground:String = this.m_orderBoard.system.getAssetUrl(FeatureCraftingSystem.ASSET_DIALOG_BACKGROUND);
      
      private var m_bgLoader:ImageLoader = null;
      
      private var m_bgIcon:DisplayObject = null;
      
      private var m_location:String = this.m_orderBoard.system.location;
      
      private var m_subtext1:String;
      
      private var m_subtext2:String;
      
      private var m_gift_mc:MovieClip = new MovieClip();
      
      public function FeatureCraftingRewardWindow(orderBoard:FeatureCraftingOrderBoard)
      {
         this.m_orderBoard = orderBoard;
         super(this.m_orderBoard.system.getAssetUrl(FeatureCraftingSystem.ASSET_DIALOG_REWARD));
         if(this.m_dialogBackground != null)
         {
            this.m_bgLoader = ImageLoader.getInstance(Global.getAssetURL(this.m_dialogBackground));
            this.m_bgLoader.getContent(this.onBgLoad);
         }
      }
      
      public static function display(orderBoard:FeatureCraftingOrderBoard) : FeatureCraftingRewardWindow
      {
         var window:FeatureCraftingRewardWindow = null;
         if(orderBoard)
         {
            window = new FeatureCraftingRewardWindow(orderBoard);
            UI.displayPopup(window,false,"FeatureCraftingRewardWindow",true);
         }
         return window;
      }
      
      private function onBgLoad(dispObj:DisplayObject, info:Object = null) : void
      {
         this.m_bgIcon = dispObj;
      }
      
      private function conditionallyDisplayJungleInnovationCard() : void
      {
         var number:int = 0;
         var type:String = null;
         if(m_window.innovation_mc)
         {
            m_window.innovation_mc.visible = false;
            if(JMInnovationManager.getInstance().isActive())
            {
               m_window.innovation_mc.visible = true;
               number = JMInnovationManager.getInstance().getRewardCount(this.m_orderBoard.system.name);
               type = JMInnovationManager.getInstance().getIngredientType(this.m_orderBoard.system.name);
               addWidget(new FarmTextField(m_window.innovation_mc.info3_tf,ZLocUtils.t("Dialogs","jungleInnovationText",{
                  "type":type,
                  "number":number
               })));
            }
         }
      }
      
      override protected function postLoadComplete() : void
      {
         var icon:FarmIcon = null;
         var partsMessage:String = null;
         var nameTextField:ZwTextField = null;
         var coinsTextField:ZwTextField = null;
         var countTextField:ZwTextField = null;
         var pointsTextField:ZwTextField = null;
         var reward:Object = null;
         var partName:String = null;
         var part:FeatureCraftingInventoryPart = null;
         var itemName:String = null;
         var item:FarmItem = null;
         var url:String = null;
         this.conditionallyDisplayJungleInnovationCard();
         this.setTemplatizedValues();
         var titleKey:String = ZLocUtils.hasString(ZLocConstants.PKG_FEATURE_CRAFTING,this.m_orderBoard.system.name + "_RewardWindow_Title") ? this.m_orderBoard.system.name + "_RewardWindow_Title" : "RewardWindow_Title";
         var rewardsKey:String = ZLocUtils.hasString(ZLocConstants.PKG_FEATURE_CRAFTING,this.m_orderBoard.system.name + "_RewardWindow_Rewards") ? this.m_orderBoard.system.name + "_RewardWindow_Rewards" : "RewardWindow_Rewards";
         var messageKey:String = ZLocUtils.hasString(ZLocConstants.PKG_FEATURE_CRAFTING,this.m_orderBoard.system.name + "_RewardWindow_Message") ? this.m_orderBoard.system.name + "_RewardWindow_Message" : "RewardWindow_Message";
         addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,titleKey))) as ZwTextField;
         if(m_window.hasOwnProperty("unlocked_tf"))
         {
            addWidget(new ZwTextField(m_window.unlocked_tf,ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,rewardsKey))) as ZwTextField;
         }
         else if(m_window.hasOwnProperty("giftbox_mc"))
         {
            this.m_gift_mc = m_window.giftbox_mc;
            this.m_gift_mc.visible = true;
         }
         var partsTextField:ZwTextField = null;
         if(m_window.hasOwnProperty("reward_tf") || m_window.hasOwnProperty("subtext2_tf"))
         {
            partsMessage = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,this.m_orderBoard.system.name + "_RewardWindow_Parts");
            partsTextField = addWidget(new ZwTextField(m_window[this.m_subtext2],partsMessage)) as ZwTextField;
         }
         var orders:Array = this.m_orderBoard.orders;
         var orderCount:int = orders ? int(orders.length) : 0;
         var messageTextField:ZwTextField = addWidget(new ZwTextField(m_window[this.m_subtext1],ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,messageKey,{"count":orderCount}))) as ZwTextField;
         if(m_window.hasOwnProperty("icon_mc"))
         {
            icon = addWidget(new FarmIcon(m_window.icon_mc)) as FarmIcon;
         }
         else if(m_window.hasOwnProperty("reward_mc"))
         {
            icon = addWidget(new FarmIcon(m_window.reward_mc)) as FarmIcon;
         }
         if(m_window.hasOwnProperty("subtext1_tf"))
         {
            icon.setIconSize(200,200);
         }
         else
         {
            icon.setIconSize(ICON_SIZE,ICON_SIZE);
         }
         icon.setSmoothing(true);
         if(m_window.hasOwnProperty("name_tf"))
         {
            nameTextField = addWidget(new ZwTextField(m_window.name_tf,"")) as ZwTextField;
         }
         if(m_window.hasOwnProperty("coins_tf"))
         {
            coinsTextField = addWidget(new ZwTextField(m_window.coins_tf,"")) as ZwTextField;
         }
         if(m_window.hasOwnProperty("count_tf"))
         {
            countTextField = addWidget(new ZwTextField(m_window.count_tf,"")) as ZwTextField;
         }
         if(m_window.hasOwnProperty("xp_tf"))
         {
            pointsTextField = addWidget(new ZwTextField(m_window.xp_tf,"")) as ZwTextField;
         }
         var rewards:Array = this.m_orderBoard.rewards;
         if(rewards)
         {
            for each(reward in rewards)
            {
               switch(reward.type)
               {
                  case FeatureCraftingSystem.REWARDS_TYPE_COIN:
                     if(m_window.hasOwnProperty("coins_tf"))
                     {
                        coinsTextField.text = String(reward[FeatureCraftingSystem.REWARDS_AMOUNT]);
                     }
                     break;
                  case FeatureCraftingSystem.REWARDS_TYPE_POINTS:
                     if(m_window.hasOwnProperty("xp_tf"))
                     {
                        pointsTextField.text = String(reward[FeatureCraftingSystem.REWARDS_AMOUNT]);
                     }
                     break;
                  case FeatureCraftingSystem.REWARDS_TYPE_INVENTORYPARTS:
                     partName = reward[FeatureCraftingSystem.REWARDS_VALUE];
                     part = this.m_orderBoard.system.getInventoryPart(partName);
                     if(part)
                     {
                        if(m_window.hasOwnProperty("name_tf"))
                        {
                           nameTextField.text = part.friendlyTitle;
                        }
                        icon.loadIcon(part.iconUrl);
                        if(Boolean(partsTextField) && ZLocUtils.hasString(ZLocConstants.PKG_FEATURE_CRAFTING,this.m_orderBoard.system.name + "_RewardWindow_DynamicParts"))
                        {
                           partsTextField.text = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,this.m_orderBoard.system.name + "_RewardWindow_DynamicParts",{"itemName":part.friendlyTitle});
                        }
                     }
                     if(m_window.hasOwnProperty("count_tf"))
                     {
                        countTextField.text = "x" + reward[FeatureCraftingSystem.REWARDS_AMOUNT];
                     }
                     break;
                  case FeatureCraftingSystem.REWARDS_TYPE_ITEMGRANT:
                     itemName = reward[FeatureCraftingSystem.REWARDS_VALUE];
                     item = Global.farmGameSettingsManager.getFarmItemByName(itemName);
                     if(item)
                     {
                        if(m_window.hasOwnProperty("name_tf"))
                        {
                           nameTextField.text = item.friendlyTitle;
                        }
                        url = item.imageRelativeUrl("feed");
                        if(url)
                        {
                           icon.loadIcon(url);
                        }
                        else
                        {
                           icon.loadIcon(item.iconUrl);
                        }
                        if(ZLocUtils.hasString(ZLocConstants.PKG_FEATURE_CRAFTING,this.m_orderBoard.system.name + "_RewardWindow_DynamicMessage"))
                        {
                           messageTextField.text = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,this.m_orderBoard.system.name + "_RewardWindow_DynamicMessage",{"item":ZLocUtils.tk_pk(item.friendlyName)});
                        }
                     }
                     if(m_window.hasOwnProperty("count_tf"))
                     {
                        countTextField.text = "x" + reward[FeatureCraftingSystem.REWARDS_AMOUNT];
                     }
               }
            }
         }
         if(this.m_orderBoardTimestamp)
         {
            addWidget(new FarmAnimatedTextButton(m_window.accept_bt,ZLocUtils.t("Dialogs","Share"),this.onShareButtonClick));
         }
         if(Boolean(m_window.mc_RewardDialog) && Boolean(this.m_bgIcon))
         {
            m_window.addChildAt(this.m_bgIcon,m_window.getChildIndex(m_window.mc_RewardDialog));
         }
         if(this.m_location != "" && TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION,this.m_location))
         {
            TemplateUIUtility.applyExpansionTextColor(m_window.title_tf);
            TemplateUIUtility.applyExpansionBevelFilter(m_window.title_tf);
            TemplateUIUtility.applyExpansionDropShadowFilter(m_window.title_tf);
            TemplateUIUtility.applyExpansionSubTextColor(m_window[this.m_subtext1]);
            if(this.m_subtext2 == "subtext2_tf")
            {
               TemplateUIUtility.applyExpansionGlowFilter(m_window[this.m_subtext2]);
            }
         }
      }
      
      private function setTemplatizedValues() : void
      {
         if(m_window.hasOwnProperty("copy_tf"))
         {
            this.m_subtext1 = "copy_tf";
         }
         else if(m_window.hasOwnProperty("subtext1_tf"))
         {
            this.m_subtext1 = "subtext1_tf";
         }
         if(m_window.hasOwnProperty("reward_tf"))
         {
            this.m_subtext2 = "reward_tf";
         }
         else if(m_window.hasOwnProperty("subtext2_tf"))
         {
            this.m_subtext2 = "subtext2_tf";
         }
      }
      
      override protected function release() : void
      {
         super.release();
      }
      
      override protected function onClose(event:Event) : void
      {
         if(m_closeButton.enabled)
         {
            super.onClose(event);
         }
      }
      
      public function onShareButtonClick(event:MouseEvent) : void
      {
         var params:Array = [this.m_orderBoard.system.name,this.m_orderBoard.timestamp];
         TransactionManager.addTransaction(new TGenericTransaction(FeatureCraftingManager.SERVICE_NAME,"postOrderBoardFeed",this.onPostFeedCallback,params),true);
         close();
      }
      
      private function onPostFeedCallback(result:Object) : void
      {
         if(Boolean(result) && Boolean(result["feedData"]))
         {
            (GlobalEngine.socialNetwork as FacebookSocialNetwork).publishResultsFromTransaction(result["feedData"]);
         }
      }
   }
}

