package Display
{
   import Classes.Constants.Experiments;
   import Classes.Constants.QuestConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.ObjectUtil;
   import Classes.util.UserRewardUtil;
   import Classes.util.ZLocFailoverEntry;
   import Classes.util.ZLocUtils;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.events.Event;
   
   public class LevelUpWorldScoreWindow extends LevelUpWindow
   {
      
      private var m_scoreUnit:String = null;
      
      private var m_cancelCallback:Function = null;
      
      public function LevelUpWorldScoreWindow(windowAssetRelUrl:String, newLevel:int, scoreUnit:String, cancelCallback:Function = null, shareCallback:Function = null, modal:Boolean = true, bAddClickBlocker:Boolean = false)
      {
         super(windowAssetRelUrl,newLevel,shareCallback,modal,bAddClickBlocker);
         this.m_scoreUnit = scoreUnit;
         this.m_cancelCallback = cancelCallback;
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         var message:String = null;
         var slotCount:Number = NaN;
         var totalSlots:Number = NaN;
         var iconSlotFrame:ZwFrame = null;
         var icon:FarmIcon = null;
         var rewardObj:Object = null;
         var headerKey:String = null;
         var delta:Number = NaN;
         super.onLoadComplete(event);
         var worldScoreName:String = ZLocUtils.t_pk("FarmGame","worldscore_short_" + this.m_scoreUnit);
         var rewards:Vector.<Object> = null;
         var nextLevel:int = m_level + 1;
         var farmItem:FarmItem = null;
         var nextLevelKeyPrefix:String = null;
         if(this.m_scoreUnit == "zen" && Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_XAS_DP_REWARD_SURFACTING) == 2 || this.m_scoreUnit == "spook" && Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_XHW_DP_REWARD_SURFACTING) == 2 || this.m_scoreUnit == "cheer" && Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_XHP_DP_REWARD_SURFACTING) == 2 || Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_DP_REWARD_SURFACTING) == 2)
         {
            nextLevelKeyPrefix = "_NextLevel";
            rewards = Global.worldScoreSettingsManager.getRewardsForLevel(this.m_scoreUnit,m_level + 1);
         }
         else
         {
            nextLevelKeyPrefix = "";
            rewards = Global.worldScoreSettingsManager.getRewardsForLevel(this.m_scoreUnit,m_level);
         }
         var unlockedFrame:ZwFrame = null;
         if(ObjectUtil.pathExists(m_window,["unlocked_mc"]))
         {
            unlockedFrame = new ZwFrame(m_window.unlocked_mc);
            addWidget(unlockedFrame);
            message = null;
            if(ObjectUtil.pathExists(m_window,["level_mc","generic_tf"]))
            {
               message = ZLocUtils.getFailoverLocString([new ZLocFailoverEntry("Dialogs",this.m_scoreUnit + "_NewLevel"),new ZLocFailoverEntry("Dialogs","worldscore_NewLevel"),new ZLocFailoverEntry("Dialogs","NewLevel")],{
                  "quantity":m_level,
                  "worldScoreName":worldScoreName,
                  "nextlevel":nextLevel
               });
               m_window.level_mc.generic_tf.text = message;
            }
            if(ObjectUtil.pathExists(m_window,["unlocked_mc","header_tf"]))
            {
               headerKey = "_LevelUpDefault_Header";
               if(rewards.length == 1)
               {
                  headerKey = "_LevelUpSingleItem_Header";
               }
               message = ZLocUtils.getFailoverLocString([new ZLocFailoverEntry("Dialogs",this.m_scoreUnit + nextLevelKeyPrefix + "_LevelUp" + m_level + "_Header"),new ZLocFailoverEntry("Dialogs",this.m_scoreUnit + nextLevelKeyPrefix + headerKey),new ZLocFailoverEntry("Dialogs","worldscore" + nextLevelKeyPrefix + headerKey)],{
                  "level":m_level,
                  "worldScoreName":worldScoreName,
                  "nextlevel":nextLevel
               });
               unlockedFrame.addWidget(new FarmTextField(m_window.unlocked_mc.header_tf,message));
            }
            if(ObjectUtil.pathExists(m_window,["unlocked_mc","subheader_tf"]))
            {
               message = ZLocUtils.getFailoverLocString([new ZLocFailoverEntry("Dialogs",this.m_scoreUnit + nextLevelKeyPrefix + "_LevelUp" + m_level + "_SubHeader"),new ZLocFailoverEntry("Dialogs",this.m_scoreUnit + nextLevelKeyPrefix + "_LevelUpDefault_SubHeader"),new ZLocFailoverEntry("Dialogs","worldscore" + nextLevelKeyPrefix + "_LevelUpDefault_SubHeader")],{
                  "level":m_level,
                  "worldScoreName":worldScoreName,
                  "nextlevel":nextLevel
               });
               unlockedFrame.addWidget(new FarmTextField(m_window.unlocked_mc.subheader_tf,message));
            }
            slotCount = 0;
            totalSlots = 3;
            iconSlotFrame = null;
            icon = null;
            for each(rewardObj in rewards)
            {
               if(rewardObj.hasOwnProperty("type") && (rewardObj.type == QuestConstants.REWARD_DISPLAY_ONLY || rewardObj.type == QuestConstants.REWARD_WORLD_CURRENCY) && rewardObj.hasOwnProperty("value"))
               {
                  if(ObjectUtil.pathExists(m_window,["unlocked_mc","slot" + slotCount.toString() + "_mc","icon_mc"]))
                  {
                     iconSlotFrame = new ZwFrame(m_window.unlocked_mc["slot" + slotCount.toString() + "_mc"]);
                     unlockedFrame.addWidget(iconSlotFrame);
                     farmItem = farmItem = Global.farmGameSettingsManager.getFarmItemByName(rewardObj.value);
                     if(null == farmItem)
                     {
                        farmItem = Global.farmGameSettingsManager.getFarmItemByCode(rewardObj.value);
                     }
                     if(farmItem)
                     {
                        iconSlotFrame.addWidget(new FarmIcon(m_window.unlocked_mc["slot" + slotCount.toString() + "_mc"]["icon_mc"],farmItem.icon));
                        iconSlotFrame.attachTooltip(new FarmTextTooltip(farmItem.friendlyTitle));
                        slotCount++;
                     }
                     else if(rewardObj.type == QuestConstants.REWARD_WORLD_CURRENCY)
                     {
                        icon = new FarmIcon(m_window.unlocked_mc["slot" + slotCount.toString() + "_mc"]["icon_mc"],UserRewardUtil.getImageForReward(rewardObj));
                        iconSlotFrame.addWidget(icon);
                        iconSlotFrame.attachTooltip(new FarmTextTooltip(rewardObj.value + " " + ZLocUtils.t_pk("FarmGame",rewardObj.unit)));
                        slotCount++;
                     }
                  }
               }
               if(slotCount >= totalSlots)
               {
                  break;
               }
            }
            switch(slotCount)
            {
               case 1:
                  m_window.unlocked_mc.slot0_mc.x = m_window.unlocked_mc.slot1_mc.x;
                  break;
               case 2:
                  delta = 0.5 * (m_window.unlocked_mc.slot1_mc.x - m_window.unlocked_mc.slot0_mc.x);
                  m_window.unlocked_mc.slot0_mc.x += delta;
                  m_window.unlocked_mc.slot1_mc.x += delta;
                  break;
               case 0:
               case 3:
            }
         }
      }
      
      override protected function onClose(event:Event) : void
      {
         super.onClose(event);
         if(this.m_cancelCallback != null)
         {
            this.m_cancelCallback();
         }
      }
   }
}

