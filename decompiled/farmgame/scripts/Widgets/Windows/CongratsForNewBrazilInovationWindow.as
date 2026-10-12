package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Engine.Managers.StatsManager;
   import Managers.OrderBoard.CarribeanInnovationManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.events.MouseEvent;
   
   public class CongratsForNewBrazilInovationWindow extends GenericSingleRewardPopup
   {
      
      private var m_featureNameBrazilInnovation:String = null;
      
      private var m_bonusItemName:String = null;
      
      private var m_shareButton:FarmAnimatedTextButton;
      
      private var m_rewardItem:FarmItem;
      
      public function CongratsForNewBrazilInovationWindow(dialogAsset:String, featureName:String, rewardItem:FarmItem, callback:Function = null, params:Object = null, bonusItemName:String = null)
      {
         this.m_featureNameBrazilInnovation = featureName;
         this.m_bonusItemName = bonusItemName;
         this.m_rewardItem = rewardItem;
         super(dialogAsset,featureName,rewardItem);
      }
      
      override protected function postLoadComplete() : void
      {
         var bonusItemName:String = null;
         var bonusItem:FarmItem = null;
         var rewardIcon:FarmIcon = null;
         super.postLoadComplete();
         if(m_window.hasOwnProperty("bonus_mc"))
         {
            bonusItemName = this.m_bonusItemName;
            if(bonusItemName)
            {
               bonusItem = Global.farmGameSettingsManager.getFarmItemByName(bonusItemName);
               m_window["bonus_mc"].visible = true;
               Global.player.addGift(bonusItemName);
               if(bonusItem)
               {
                  if(Boolean(m_window["bonus_mc"].hasOwnProperty("name_tf")) && Boolean(m_window["bonus_mc"].hasOwnProperty("icon2_mc")))
                  {
                     addWidget(new ZwTextField(m_window["bonus_mc"]["name_tf"],bonusItem.friendlyTitle));
                     rewardIcon = addWidget(new FarmIcon(m_window["bonus_mc"].icon2_mc)) as FarmIcon;
                     rewardIcon.setIconSize(100,100);
                     rewardIcon.setSmoothing(true);
                     rewardIcon.loadIcon(bonusItem.iconUrl);
                     rewardIcon.visible = true;
                  }
               }
            }
         }
         if(m_window.hasOwnProperty("okay_bt"))
         {
            addWidget(new FarmAnimatedTextButton(m_window["okay_bt"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_featureName + "okayBtnTxt"),this.closePopup));
            getWidget(m_window["share_bt"]).visible = false;
         }
      }
      
      public function closePopup(event:MouseEvent = null) : void
      {
         StatsManager.count("DragonvalleyInnovation","TempleChoice","VisitTemple");
         super.close();
         var featureName:String = this.m_featureNameBrazilInnovation.substring(0,this.m_featureNameBrazilInnovation.length - 13);
         CarribeanInnovationManager.getInstance(featureName).panToBuilding(this.m_rewardItem.name);
      }
   }
}

