package Widgets.Slots.Equipment
{
   import Classes.OrchardFeatureBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Transactions.TCancelFriendReward;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.Equipment.ResourceHarvesterRewardSlotContainerFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.Equipment.ResourceHarvesterRewardWindow;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class ResourceHarvesterRewardSlot extends ZwSlotFrame
   {
      
      private static const ICON_SIZE:int = 100;
      
      protected var m_data:Array;
      
      private var m_isSeed:Boolean;
      
      private var m_itemCode:String;
      
      private var m_itemCount:int;
      
      private var m_rewardIndex:int;
      
      private var m_icon:FarmIcon;
      
      private var m_nameTextField:ZwTextField;
      
      private var m_shareMessageTextField:ZwTextField;
      
      private var m_shareCountTextField:ZwTextField;
      
      private var m_shareButton:FarmAnimatedTextButton;
      
      private var m_bundleID:String = null;
      
      private var m_isWaitingForTransaction:Boolean = false;
      
      public function ResourceHarvesterRewardSlot(element:DisplayObject)
      {
         super(element);
         this.m_icon = addWidget(new FarmIcon(m_element.icon_mc)) as FarmIcon;
         this.m_icon.setIconSize(ICON_SIZE,ICON_SIZE);
         this.m_icon.setSmoothing(true);
         this.m_nameTextField = addWidget(new ZwTextField(m_element.copy_tf,"")) as ZwTextField;
         this.m_shareMessageTextField = addWidget(new ZwTextField(m_element.subcopy2_tf,ZLocUtils.t("Dialogs",ResourceHarvesterRewardWindow.DIALOG_TEXT_ZLOC_KEY_PREFIX + "_ShareLabel"))) as ZwTextField;
         this.m_shareCountTextField = addWidget(new ZwTextField(m_element.subcopy_tf,"")) as ZwTextField;
         this.m_shareButton = addWidget(new FarmAnimatedTextButton(m_element.share_bt,"Share",this.onShareButtonClick)) as FarmAnimatedTextButton;
      }
      
      override public function release() : void
      {
         this.m_data = null;
         this.m_icon = null;
         this.m_nameTextField = null;
         this.m_shareMessageTextField = null;
         this.m_shareCountTextField = null;
         this.m_shareButton = null;
         this.m_itemCount = 0;
         super.release();
      }
      
      override public function populate(data:Object) : void
      {
         var reward:Object = null;
         var imageUrl:String = null;
         var item:FarmItem = null;
         var rewardText:String = null;
         super.populate(data);
         this.m_data = data as Array;
         if(this.m_data)
         {
            if(this.m_data[this.m_data.length - 1].rewardIndex)
            {
               this.m_rewardIndex = this.m_data[this.m_data.length - 1].rewardIndex;
            }
            else
            {
               this.m_data[this.m_data.length - 1].rewardIndex = this.m_rewardIndex = 0;
            }
            this.m_itemCount = 0;
            for each(reward in this.m_data)
            {
               this.m_itemCount += reward.itemCount;
            }
            this.m_isSeed = reward.isSeed ? true : false;
            item = null;
            if(reward.itemCode)
            {
               this.m_itemCode = reward.itemCode;
               item = Global.farmGameSettingsManager.getFarmItemByCode(this.m_itemCode);
               imageUrl = item.iconUrl;
               rewardText = ZLocUtils.t("Dialogs",ResourceHarvesterRewardWindow.DIALOG_TEXT_ZLOC_KEY_PREFIX + "_Item",{
                  "quantity":this.m_itemCount,
                  "item":ZLocUtils.tk_pk(item.friendlyName,"",this.m_itemCount)
               });
            }
            else
            {
               imageUrl = reward.imageUrl;
               rewardText = ZLocUtils.t("Dialogs",ResourceHarvesterRewardWindow.DIALOG_TEXT_ZLOC_KEY_PREFIX + "_No_Item",{
                  "quantity":this.m_itemCount,
                  "item":reward.friendlyTitle
               });
            }
            if(reward.bundleID)
            {
               this.m_bundleID = reward.bundleID;
            }
            this.m_icon.loadIcon(imageUrl);
            this.m_icon.visible = true;
            this.m_nameTextField.text = rewardText;
            this.m_nameTextField.visible = true;
            this.m_shareMessageTextField.visible = true;
            this.refreshShareButton();
         }
      }
      
      public function refreshShareButton() : void
      {
         var shareCount:int = 0;
         var shareTextKey:String = null;
         if(this.m_data)
         {
            if(this.hasMoreRewards)
            {
               shareCount = this.m_data.length - this.m_rewardIndex;
               shareTextKey = ResourceHarvesterRewardWindow.DIALOG_TEXT_ZLOC_KEY_PREFIX + "_ShareCount";
               shareTextKey += shareCount == 1 ? "_Singular" : "_Plural";
               this.m_shareCountTextField.text = ZLocUtils.t("Dialogs",shareTextKey,{"quantity":shareCount});
               this.m_shareCountTextField.visible = true;
               this.m_shareButton.enabled = !this.m_isWaitingForTransaction;
               this.m_shareButton.visible = true;
            }
            else
            {
               this.m_shareCountTextField.text = ZLocUtils.t("Dialogs",ResourceHarvesterRewardWindow.DIALOG_TEXT_ZLOC_KEY_PREFIX + "_ShareCount_NoneLeft");
               this.m_shareCountTextField.visible = true;
               this.m_shareButton.enabled = false;
               this.m_shareButton.visible = false;
            }
         }
      }
      
      public function get hasMoreRewards() : Boolean
      {
         return this.m_rewardIndex < this.m_data.length;
      }
      
      public function set shareButtonEnabled(value:Boolean) : void
      {
         this.m_shareButton.enabled = value;
         this.m_isWaitingForTransaction = !value;
      }
      
      private function onShareButtonClick(event:MouseEvent) : void
      {
         var bundleId:String = null;
         var params:Object = null;
         var rewardItem:FarmItem = null;
         var rewardLink:String = null;
         if(this.m_shareButton.enabled)
         {
            if(this.m_bundleID)
            {
               Global.farmSocialNetwork.publishFeedStory(this.m_bundleID,this.m_data[0].feedBundleData,[],false,this.onFeedClosed);
            }
            else
            {
               bundleId = this.m_isSeed ? OrchardFeatureBuilding.MYSTERY_SEED_FOUND_FEED_BUNDLE_ID : OrchardFeatureBuilding.CONSOLATION_GIFT_BUNDLE_ID;
               params = new Object();
               params.sendingUser = Global.player.firstName;
               rewardItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_itemCode);
               rewardLink = this.m_data[0].rewardLink;
               params.rewardLink = rewardLink;
               params.images = [{
                  "src":rewardItem.newsfeed,
                  "href":"{SN_APP_URL}" + rewardLink
               }];
               GlobalEngine.socialNetwork.publishFeedStory(bundleId,params,[],false,this.onFeedClosed);
            }
            this.m_data[this.m_data.length - 1].rewardIndex = ++this.m_rewardIndex;
            this.refreshShareButton();
            (parent as ResourceHarvesterRewardSlotContainerFrame).disableShareButtons();
            (parent as ResourceHarvesterRewardSlotContainerFrame).incrementSharedCount();
            (getAncestorByClassType(ResourceHarvesterRewardWindow) as ResourceHarvesterRewardWindow).checkNoMoreRewards();
         }
      }
      
      private function onFeedClosed() : void
      {
         if(parent)
         {
            (parent as ResourceHarvesterRewardSlotContainerFrame).enableShareButtons();
            (parent as ResourceHarvesterRewardSlotContainerFrame).refreshShareButtons();
         }
      }
      
      public function cancelFriendRewards() : void
      {
         var rewardUrls:Array = null;
         var i:int = 0;
         if(this.m_data)
         {
            rewardUrls = [];
            for(i = this.m_rewardIndex; i < this.m_data.length; i++)
            {
               rewardUrls.push(this.m_data[i].rewardLink);
            }
            if(rewardUrls.length > 0)
            {
               TransactionManager.addTransaction(new TCancelFriendReward(rewardUrls));
            }
         }
      }
   }
}

