package Widgets.Slots
{
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Managers.OrderBoard.HalloweenInnovationManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class HalloweenUSAInnovationRewardsSlot extends ZwSlotFrame
   {
      
      private var m_featureName:String;
      
      private var m_slotIcon:FarmIcon;
      
      private var m_gamesTf:ZwTextField;
      
      private var m_countTf:ZwTextField;
      
      private var m_playBt:FarmAnimatedTextButton;
      
      private var m_checkMarkMc:MovieClip;
      
      private var m_slotIndex:int;
      
      private var m_data:Object;
      
      private var m_toolTip:FarmTextTooltip;
      
      private var m_isIconPreviewAdded:Boolean = false;
      
      protected var m_iconPreview:ObjectPreviewFrame;
      
      private var m_item:FarmItem;
      
      public function HalloweenUSAInnovationRewardsSlot(element:DisplayObject, featureName:String)
      {
         this.m_featureName = featureName;
         super(element);
         (m_element as MovieClip).visible = true;
         if(m_element.hasOwnProperty("games_tf"))
         {
            addWidget(this.m_gamesTf = new ZwTextField(m_element["games_tf"],"Games Won"));
         }
         if(m_element.hasOwnProperty("count_tf"))
         {
            addWidget(this.m_countTf = new ZwTextField(m_element["count_tf"],"10"));
         }
         if(m_element.hasOwnProperty("play_bt"))
         {
            addWidget(this.m_playBt = new FarmAnimatedTextButton(m_element["play_bt"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_reward_btn"),this.playButtonCallback));
            this.m_playBt.attachTooltip(new FarmTextTooltip(ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_reward_btn_hover")));
         }
         if(m_element.hasOwnProperty("checkmark_mc"))
         {
            this.m_checkMarkMc = m_element["checkmark_mc"] as MovieClip;
         }
      }
      
      override public function populate(data:Object) : void
      {
         var icon:FarmIcon = null;
         super.populate(data);
         this.m_data = data;
         this.m_slotIndex = this.m_data.index;
         (m_element as MovieClip).visible = true;
         this.m_playBt.visible = true;
         this.m_gamesTf.visible = true;
         this.m_countTf.visible = true;
         this.m_checkMarkMc.visible = false;
         if(m_element.hasOwnProperty("slot_icon_mc"))
         {
            this.m_item = Global.farmGameSettingsManager.getFarmItemByCode(this.m_data.code);
            icon = new FarmIcon(m_element["slot_icon_mc"] as MovieClip,this.m_item.iconUrl);
            icon.detachTooltip();
            if(this.m_toolTip)
            {
               this.m_toolTip.setText(this.m_item.friendlyTitle);
            }
            else
            {
               icon.attachTooltip(this.m_toolTip = new FarmTextTooltip(this.m_item.friendlyTitle));
            }
            icon.visible = true;
         }
         var winCountStr:String = HalloweenInnovationManager.getInstance().getWinCountForReward(this.m_data.code).toString();
         this.m_countTf.text = winCountStr + "/" + this.m_data.required;
         if(HalloweenInnovationManager.getInstance().isRewardClaimed(this.m_data.code))
         {
            this.m_checkMarkMc.visible = true;
         }
         this.m_countTf.text = winCountStr + "/" + data.required;
         if(HalloweenInnovationManager.getInstance().canUserStartPlaying() == false)
         {
            this.m_playBt.callback = null;
            FarmGameUtil.disableButtonAndShowTooltip(this.m_playBt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_reward_btn_hover"));
         }
         else
         {
            this.m_playBt.callback = this.playButtonCallback;
            this.m_playBt.enabled = true;
         }
      }
      
      private function playButtonCallback(event:MouseEvent) : void
      {
         var currentTierName:String = "";
         if(HalloweenInnovationManager.getInstance().mainWindow)
         {
            currentTierName = HalloweenInnovationManager.getInstance().mainWindow.currentTabName();
         }
         var winCount:String = HalloweenInnovationManager.getInstance().getWinCountForReward(this.m_data.code).toString();
         FarmStatsManager.count("RockPaperShivers","Main_UI","find_game",this.m_item.name,currentTierName,winCount,this.m_data.required);
         var itemCode:String = this.m_data.code;
         HalloweenInnovationManager.getInstance().initializeGameWindow(itemCode);
      }
   }
}

