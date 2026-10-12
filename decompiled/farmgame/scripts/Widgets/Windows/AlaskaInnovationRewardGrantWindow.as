package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Engine.Managers.StatsManager;
   import Managers.OrderBoard.DreamWorldInnovationManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import flash.events.MouseEvent;
   
   public class AlaskaInnovationRewardGrantWindow extends GenericSingleRewardPopup
   {
      
      private var m_bonusItemName:Array = null;
      
      private var m_shareButton:FarmAnimatedTextButton;
      
      private var m_rewardItem:FarmItem;
      
      private const m_bonusItems:Array;
      
      public function AlaskaInnovationRewardGrantWindow(dialogAsset:String, featureName:String, rewardItem:FarmItem, callback:Function = null, dialogBackground:String = null, bonusItems:Array = null)
      {
         var i:int = 0;
         this.m_bonusItems = new Array();
         m_featureName = featureName;
         if(bonusItems)
         {
            for(i = 0; i < bonusItems.length; i++)
            {
               this.m_bonusItems[i] = bonusItems[i];
            }
         }
         this.m_rewardItem = rewardItem;
         super(dialogAsset,featureName,rewardItem,callback,dialogBackground);
      }
      
      override protected function postLoadComplete() : void
      {
         var i:int = 0;
         super.postLoadComplete();
         if(this.m_bonusItems)
         {
            i = 0;
            while(i < this.m_bonusItems.length)
            {
               Global.player.addGift(this.m_bonusItems[i]);
               i++;
            }
         }
         if(m_window.hasOwnProperty("okay_bt"))
         {
            addWidget(new FarmAnimatedTextButton(m_window["okay_bt"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_featureName + "okayBtnTxt"),this.closePopup));
            getWidget(m_window["share_bt"]).visible = false;
         }
      }
      
      override protected function afterLoad() : void
      {
         if(m_window.hasOwnProperty("close_bt"))
         {
            setCloseButtonVisible(false);
         }
         if(m_window.hasOwnProperty("bonus_mc"))
         {
            m_window["bonus_mc"].visible = false;
         }
         if(m_window.hasOwnProperty("giftbox_mc"))
         {
            m_window["giftbox_mc"].visible = false;
         }
      }
      
      public function closePopup(event:MouseEvent = null) : void
      {
         StatsManager.count("AlaskaInnovation","TempleChoice","VisitTemple");
         super.close();
         var featureName:String = m_featureName.substring(0,m_featureName.length - 13);
         DreamWorldInnovationManager.getInstance(featureName).panToBuilding(this.m_rewardItem.name);
      }
   }
}

