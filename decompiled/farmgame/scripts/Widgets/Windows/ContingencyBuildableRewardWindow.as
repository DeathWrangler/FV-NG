package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.TextFields.FarmTextField;
   
   public class ContingencyBuildableRewardWindow extends FarmWindow
   {
      
      private static const ASSET_PATH:String = "assets/dialogs/FV_ContingencyBuildable_MultipleReward.swf";
      
      private var m_rewardItems:Array;
      
      private var m_findInGiftBoxTf:FarmTextField;
      
      private var m_buildingName:String;
      
      public function ContingencyBuildableRewardWindow(buildingName:String, rewardItems:Array)
      {
         super(ASSET_PATH);
         this.m_rewardItems = rewardItems;
         this.m_buildingName = buildingName;
      }
      
      override protected function postLoadComplete() : void
      {
         var buildingItem:FarmItem = null;
         super.postLoadComplete();
         var index:int = 1;
         while(m_window.hasOwnProperty("reward_" + index + "_mc"))
         {
            addWidget(new ZwFrame(m_window["reward_" + index + "_mc"]),false) as ZwFrame;
            index++;
         }
         if(m_window.hasOwnProperty("title_tf"))
         {
            buildingItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_buildingName);
            addWidget(new FarmTextField(m_window["title_tf"],buildingItem.friendlyTitle),true);
         }
         if(m_window.hasOwnProperty("info2_tf"))
         {
            addWidget(new FarmTextField(m_window["info2_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"bldg_soupkitchen_giftBoxMessage")),true);
         }
         if(m_window.hasOwnProperty("accept_bt"))
         {
            addWidget(new FarmAnimatedTextButton(m_window["accept_bt"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"OkButton"),onClose),true);
         }
         this.populateRewards();
      }
      
      private function populateRewards() : void
      {
         var item:FarmItem = null;
         var mcInsName:String = "reward_" + this.m_rewardItems.length + "_mc";
         var rewardFrame:ZwFrame = getWidget(m_window[mcInsName]) as ZwFrame;
         for(var i:int = 0; i < this.m_rewardItems.length; i++)
         {
            item = Global.farmGameSettingsManager.getFarmItemByName(this.m_rewardItems[i].rewardItem);
            if(m_window[mcInsName].hasOwnProperty("icon_" + i + "_mc"))
            {
               rewardFrame.addWidget(new FarmIcon(m_window[mcInsName]["icon_" + i + "_mc"],item.icon),true);
            }
            if(m_window[mcInsName].hasOwnProperty("reward_tf_" + i))
            {
               rewardFrame.addWidget(new FarmTextField(m_window[mcInsName]["reward_tf_" + i],"x" + this.m_rewardItems[i].numRewards.toString()),true);
            }
         }
         rewardFrame.visible = true;
      }
   }
}

