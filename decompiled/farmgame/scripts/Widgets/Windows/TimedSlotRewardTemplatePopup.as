package Widgets.Windows
{
   import Classes.ZItem.FarmItem;
   import Managers.TemplateUIUtility;
   import Managers.TimedSlotGiveawaysManager;
   import Widgets.Icons.FarmIcon;
   
   public class TimedSlotRewardTemplatePopup extends GenericSingleRewardPopup
   {
      
      public function TimedSlotRewardTemplatePopup(dialogAsset:String, featureName:String, rewardItem:FarmItem, buttonCallback:Function = null)
      {
         super(dialogAsset,featureName,rewardItem,buttonCallback);
      }
      
      override protected function postLoadComplete() : void
      {
         var titleColor:String = null;
         super.postLoadComplete();
         if(TimedSlotGiveawaysManager.isTemplateUIEnabled(m_featureName))
         {
            if(m_window.hasOwnProperty("background_mc"))
            {
               addWidget(new FarmIcon(m_window.background_mc,TimedSlotGiveawaysManager.getRewardBackground(m_featureName)));
            }
            titleColor = TimedSlotGiveawaysManager.getTitleColor(m_featureName);
            if(Boolean(title_tf) && Boolean(titleColor != null) && titleColor != "")
            {
               TemplateUIUtility.applyTextColor(title_tf,TemplateUIUtility.FARM_STAND,titleColor);
            }
         }
      }
   }
}

