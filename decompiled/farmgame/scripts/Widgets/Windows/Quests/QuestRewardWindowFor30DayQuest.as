package Widgets.Windows.Quests
{
   import Classes.Avatar.AvatarItem;
   import Classes.Avatar.AvatarManager;
   import Classes.Constants.Experiments;
   import Classes.Constants.QuestConstants;
   import Classes.Quest.FarmQuest;
   import Classes.Quest.FarmQuestManager;
   import Classes.ZItem.ConsumableItem;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Engine.Events.TransactionEvent;
   import Engine.Managers.TransactionManager;
   import Managers.FarmStatsManager;
   import Transactions.Quests.TShareQuestLoot;
   import Transactions.TBuyAvatarItem;
   import Transactions.TBuyItemPutGiftbox;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Constants.Market.Currency;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Interfaces.IQuestRewardView;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class QuestRewardWindowFor30DayQuest extends WindowWithRewardItem implements IQuestRewardView
   {
      
      private static const DEFAULT_ASSET_URL:String = "assets/dialogs/FV_QuestRewardDialog2014.swf";
      
      private static const ASSET_KEY_POSTFIX:String = "_shareWindow";
      
      private var m_farmQuest:FarmQuest = null;
      
      private var m_purchaseData:Object = null;
      
      private var m_buyItemBtn:FarmAnimatedCashButton;
      
      public function QuestRewardWindowFor30DayQuest(farmQuest:FarmQuest)
      {
         var assetUrl:String = Global.farmGameSettingsManager.getAttribute(farmQuest.name + ASSET_KEY_POSTFIX,DEFAULT_ASSET_URL);
         super(assetUrl);
         this.m_farmQuest = farmQuest;
      }
      
      override protected function getTitle() : String
      {
         return this.m_farmQuest.titleText;
      }
      
      override protected function getRewardText() : String
      {
         return this.m_farmQuest.rewardText;
      }
      
      override protected function getRewardShareButtonText() : String
      {
         return this.m_farmQuest.rewardShareButtonText;
      }
      
      override protected function getExtraRewardText() : String
      {
         return this.m_farmQuest.extraRewardText;
      }
      
      override protected function getRewardButtonText() : String
      {
         return this.m_farmQuest.rewardShareButtonText;
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         this.showNPC();
      }
      
      override public function show() : void
      {
         super.show();
         FarmStatsManager.count("fv_quest",this.m_farmQuest.name,"reward","impression");
      }
      
      override protected function showRewardItem(farmItem:FarmItem) : void
      {
         var icon:FarmIcon = null;
         var itemPreview:ObjectPreviewFrame = null;
         var lastQuest:FarmQuest = null;
         var reward:Object = null;
         var avatarItem:AvatarItem = null;
         farmItem = null;
         var index:int = 0;
         var icon_mc:String = "icon_mc";
         var icon_tf:String = "icon_tf";
         if(this.m_farmQuest.farmRewards.length > 0)
         {
            for each(reward in this.m_farmQuest.farmRewards)
            {
               icon_mc = "icon_" + index + "_mc";
               icon_tf = "icon_" + index + "_tf";
               if(m_window[icon_mc])
               {
                  if(reward.type == QuestConstants.REWARD_GRANT_ITEM)
                  {
                     farmItem = Global.farmGameSettingsManager.getFarmItemByCode(reward.value);
                     lastQuest = FarmQuestManager.getInstance().getLastQuestInList(this.m_farmQuest);
                     if(this.m_farmQuest.name != lastQuest.name)
                     {
                        icon_mc = "icon_3_mc";
                     }
                     if(!(farmItem is ConsumableItem))
                     {
                        itemPreview = new ObjectPreviewFrame(m_window[icon_mc],farmItem,null,null,[PREVIEWWIDTH]);
                        itemPreview.y += PREVIEWWIDTH / 2;
                        addWidget(itemPreview);
                     }
                     else
                     {
                        icon = new FarmIcon(m_window[icon_mc],farmItem.icon);
                        icon.y += icon.height / 5;
                        addWidget(icon);
                     }
                     if(m_window[icon_tf])
                     {
                        addWidget(new ZwTextField(m_window[icon_tf],farmItem.friendlyTitle));
                     }
                  }
                  else if(reward.type == QuestConstants.REWARD_AVATAR_ITEM)
                  {
                     icon = new FarmIcon(m_window[icon_mc],this.m_farmQuest.getImageForRewardAtIndex(index));
                     addWidget(icon);
                     if(Boolean(m_window[icon_tf]) && Boolean(reward.value))
                     {
                        avatarItem = Global.avatarConfigSettings.getItemById(reward.value);
                        if(avatarItem)
                        {
                           addWidget(new ZwTextField(m_window[icon_tf],ZLocUtils.tk_pk_asTitle(avatarItem.friendlyName)));
                        }
                     }
                  }
                  else
                  {
                     icon = new FarmIcon(m_window[icon_mc],this.m_farmQuest.getImageForRewardAtIndex(index));
                     addWidget(icon);
                     if(Boolean(m_window[icon_tf]) && Boolean(reward.value))
                     {
                        addWidget(new ZwTextField(m_window[icon_tf],"x" + reward.value));
                     }
                  }
                  if(Boolean(m_window.buymore_bt) && (reward.type == QuestConstants.REWARD_GRANT_ITEM || reward.type == QuestConstants.REWARD_AVATAR_ITEM))
                  {
                     this.m_purchaseData = this.m_farmQuest.getPurchaseDataAtIndex(index);
                     if(Boolean(this.m_purchaseData && this.m_purchaseData.buyable && this.m_purchaseData.marketType == Currency.CASH) && Boolean(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_QUEST_REWARD_PURCHASE) > 1) && Global.player.hasGiftBoxCapacity())
                     {
                        this.m_buyItemBtn = new FarmAnimatedCashButton(m_window.buymore_bt,"Buy More",farmItem.cash.toString(),this.onBuyButtonPressed);
                        addWidget(this.m_buyItemBtn);
                     }
                  }
               }
               index++;
            }
         }
      }
      
      public function postRewardFeed(rewardLink:String) : void
      {
         var creativeBundleName:String = null;
         var item:FarmItem = null;
         var bundleData:Object = null;
         if(rewardLink != null)
         {
            creativeBundleName = this.m_farmQuest.creativeBundleName;
            item = this.m_farmQuest.friendRewardItem;
            if(creativeBundleName != null && creativeBundleName != "" && item != null)
            {
               bundleData = {
                  "actor":Global.player.firstName,
                  "reward_link":rewardLink,
                  "item_name":item.friendlyName,
                  "images":[{
                     "src":Global.getAssetURL(this.m_farmQuest.completeShareFeedIcon),
                     "href":Config.SN_APP_URL + rewardLink
                  }]
               };
               FarmStatsManager.count("fv_quest",this.m_farmQuest.name,"reward","feed_click");
               GlobalEngine.socialNetwork.publishFeedStory(creativeBundleName,bundleData,[],false);
            }
         }
         close();
      }
      
      override protected function onShareClick(event:MouseEvent) : void
      {
         TransactionManager.addTransaction(new TShareQuestLoot(this.m_farmQuest.name,true,this),true);
         super.onShareClick(event);
      }
      
      override protected function onClose(event:Event) : void
      {
         TransactionManager.addTransaction(new TShareQuestLoot(this.m_farmQuest.name,false,this),true);
         super.onClose(event);
      }
      
      private function showNPC() : void
      {
         if(m_window.npc_mc)
         {
            addWidget(new FarmIcon(m_window.npc_mc,this.m_farmQuest.avatarBodyImage));
         }
      }
      
      private function onBuyButtonPressed(event:Event) : void
      {
         var farmItem:FarmItem = null;
         var avatarItem:AvatarItem = null;
         if(this.m_purchaseData.item is FarmItem)
         {
            this.m_buyItemBtn.enabled = false;
            farmItem = this.m_purchaseData.item as FarmItem;
            if(Global.player.buyFarmItem(farmItem,Currency.CASH,1,true))
            {
               TransactionManager.getInstance().addEventListener(TransactionEvent.COMPLETED,this.onPurchaseTransactionComplete);
               FarmStatsManager.count("Quest_reward_purchase",farmItem.name,String(farmItem.cash));
            }
            else
            {
               this.m_buyItemBtn.enabled = true;
            }
         }
         else if(this.m_purchaseData.item is AvatarItem)
         {
            avatarItem = this.m_purchaseData.item as AvatarItem;
            AvatarManager.buyAvatarItem(avatarItem.itemId);
         }
      }
      
      private function onPurchaseTransactionComplete(event:TransactionEvent) : void
      {
         if(Boolean(this.m_buyItemBtn) && (event.transaction is TBuyItemPutGiftbox || event.transaction is TBuyAvatarItem))
         {
            TransactionManager.getInstance().removeEventListener(TransactionEvent.COMPLETED,this.onPurchaseTransactionComplete);
            this.m_buyItemBtn.enabled = true;
         }
      }
   }
}

