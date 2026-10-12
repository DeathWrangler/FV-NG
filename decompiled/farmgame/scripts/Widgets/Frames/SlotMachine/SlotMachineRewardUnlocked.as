package Widgets.Frames.SlotMachine
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class SlotMachineRewardUnlocked extends ZwFrame
   {
      
      private static const ITEM_IMAGE_NAME:String = "icon";
      
      private var m_rewardUnlockedLayer:ZwFrame;
      
      private var m_rewardIcon:FarmIcon;
      
      private var m_rewardTextName:ZwTextField;
      
      private var m_title:ZwTextField;
      
      private var m_rewardTextOther:ZwTextField;
      
      private var m_claimBtn:FarmAnimatedTextButton;
      
      private var m_claimRewardCallback:Function;
      
      private var m_buildingName:String;
      
      public function SlotMachineRewardUnlocked(element:DisplayObject, buildingName:String, claimRewardCallback:Function)
      {
         super(element);
         this.m_buildingName = buildingName;
         this.m_rewardUnlockedLayer = addWidget(new ZwFrame(m_element as DisplayObject)) as ZwFrame;
         this.m_rewardIcon = addWidget(new FarmIcon(m_element.icon_mc)) as FarmIcon;
         this.m_title = addWidget(new ZwTextField(m_element.generic_tf,ZLocUtils.t("Dialogs",buildingName + "_CollectionReward"))) as ZwTextField;
         this.m_rewardTextName = addWidget(new ZwTextField(m_element.generic2_tf,"")) as ZwTextField;
         this.m_rewardTextOther = addWidget(new ZwTextField(m_element.generic3_tf,"")) as ZwTextField;
         this.m_rewardTextOther.text = ZLocUtils.t("Dialogs",this.m_buildingName + "_WishingWellLevelUp");
         this.m_claimBtn = addWidget(new FarmAnimatedTextButton(m_element.claim_bt,ZLocUtils.t("Dialogs",this.m_buildingName + "_ClaimReward"),this.onClaimReward)) as FarmAnimatedTextButton;
         this.m_claimRewardCallback = claimRewardCallback;
      }
      
      public function setReward(item:FarmItem, claimIsActive:Boolean, levelsRemainingToComplete:Number) : void
      {
         this.m_rewardIcon.loadIcon(item.getImageByName("icon"));
         this.m_rewardTextName.text = ZLocUtils.tk_pk_asTitle(item.friendlyName);
         this.m_rewardTextOther.text = ZLocUtils.t("Dialogs",this.m_buildingName + "_WishingWellLevelUp");
         this.m_claimBtn.enabled = claimIsActive;
         this.m_claimBtn.visible = claimIsActive;
      }
      
      public function onClaimReward(event:MouseEvent) : void
      {
         this.m_claimBtn.enabled = false;
         this.m_claimBtn.visible = false;
         if(this.m_claimRewardCallback != null)
         {
            this.m_claimRewardCallback(event);
         }
      }
      
      public function updateClaimed(hasBeenClaimed:Boolean) : void
      {
         if(hasBeenClaimed == this.m_rewardTextOther.visible)
         {
            if(hasBeenClaimed)
            {
               this.m_title.text = ZLocUtils.t("Dialogs",this.m_buildingName + "_CollectionClaimed");
               this.m_rewardTextOther.visible = false;
            }
            else
            {
               this.m_title.text = ZLocUtils.t("Dialogs",this.m_buildingName + "_CollectionReward");
               this.m_rewardTextOther.visible = true;
            }
         }
      }
   }
}

