package Classes
{
   import Classes.Constants.QuestConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.UserRewardUtil;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Events.ActionDropEvent;
   import Events.DynamicObjectEvent;
   import Managers.ActionDropsManager;
   
   public class GypsyTraderActionDropHandler
   {
      
      private static var m_featureName:String;
      
      public function GypsyTraderActionDropHandler()
      {
         super();
      }
      
      public static function registerActionDropsListener(initParams:Object, params:XML) : void
      {
         m_featureName = params.featureName;
         ActionDropsManager.getInstance().addEventListener(ActionDropsManager.EVENT_ACTION_DROPS_UPDATED,refreshActionDropStatus);
      }
      
      private static function refreshActionDropStatus(event:DynamicObjectEvent) : void
      {
         var actionDropName:String = null;
         var actionDropSetting:XML = null;
         var rewardMultiplier:int = 0;
         var actionDropRewards:Vector.<Object> = null;
         var centerX:Number = NaN;
         var centerY:Number = NaN;
         var i:int = 0;
         var reward:Object = null;
         var statusMessage:String = null;
         var actionDropsData:Object = event.data;
         if(actionDropsData != null)
         {
            for(actionDropName in actionDropsData)
            {
               if(m_featureName.indexOf(actionDropName) >= 0)
               {
                  actionDropSetting = ActionDropsManager.getInstance().getActionDropXML(actionDropName);
                  rewardMultiplier = int(actionDropsData[actionDropName]["dropTypeFuncResult"]);
                  if(rewardMultiplier > 0)
                  {
                     UserRewardUtil.grantUserRewardsFromXml(actionDropSetting.rewards[0],rewardMultiplier);
                     actionDropRewards = UserRewardUtil.getRewardsVectorFromXml(actionDropSetting.rewards[0]);
                     centerX = Global.stage.stageWidth / 2;
                     for(centerY = Global.stage.stageHeight / 2 - 150; i < actionDropRewards.length; )
                     {
                        reward = actionDropRewards[i];
                        statusMessage = getDooberStatusMessage(reward,rewardMultiplier);
                        dispatchDooberUpdateEvent(reward,rewardMultiplier);
                        UI.displayStatus(statusMessage,centerX,centerY,UserRewardUtil.getImageForReward(reward),null,UI.DEFAULT_STATUS_TWEEN_DURATION,UI.DEFAULT_STATUS_TWEEN_DISPLACEMENT,UI.DEFAULT_STATUS_TWEEN_FONT_SIZE,UI.STATUS_TWEEN_FONT_COLOR_WHITE);
                        i++;
                     }
                  }
               }
            }
         }
      }
      
      private static function getDooberStatusMessage(reward:Object, multiplier:int) : String
      {
         var item:FarmItem = null;
         var result:String = "";
         if(reward != null)
         {
            switch(reward.type)
            {
               case QuestConstants.REWARD_GRANT_ITEM:
                  item = Global.farmGameSettingsManager.getFarmItemByCode(reward.value);
                  result = reward.quantity != null ? ZLocUtils.t("Dialogs","ItemGrantStatusDoober",{
                     "quantity":reward.quantity * multiplier,
                     "item":ZLocUtils.tk_pk_asTitle("Items:" + item.name + "_friendlyName")
                  }) : "";
                  break;
               default:
                  result = UserRewardUtil.getValueForReward(reward);
            }
         }
         return result;
      }
      
      private static function dispatchDooberUpdateEvent(reward:Object, multiplier:int) : void
      {
         var item:FarmItem = null;
         var amount:int = 0;
         var evtObj:Object = null;
         var actionDropEvent:ActionDropEvent = null;
         if(reward)
         {
            if(reward.type == QuestConstants.REWARD_GRANT_ITEM)
            {
               item = Global.farmGameSettingsManager.getFarmItemByCode(reward.value);
               amount = reward.quantity * multiplier;
               evtObj = new Object();
               evtObj.item = item;
               evtObj.amount = amount;
               actionDropEvent = new ActionDropEvent(ActionDropsManager.EVENT_DOOBER_PROGRESS,evtObj);
               ActionDropsManager.getInstance().dispatchEvent(actionDropEvent);
            }
         }
      }
   }
}

