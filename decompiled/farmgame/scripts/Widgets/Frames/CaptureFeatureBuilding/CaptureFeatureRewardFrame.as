package Widgets.Frames.CaptureFeatureBuilding
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObject;
   
   public class CaptureFeatureRewardFrame extends ZwFrame
   {
      
      public function CaptureFeatureRewardFrame(element:DisplayObject, rewards:Array, iconWidth:int, iconHeight:int, permute:Boolean)
      {
         var type:String = null;
         var value:String = null;
         var icon:FarmIcon = null;
         var rewardCountString:String = null;
         var rewardIconString:String = null;
         var item:FarmItem = null;
         super(element);
         if(m_element.hasOwnProperty("reward_tf"))
         {
            addWidget(new ZwTextField(m_element.reward_tf,ZLocUtils.t("Dialogs","GopherGarden_GopherReward")));
         }
         var numRewards:int = int(rewards.length);
         if(permute && numRewards > 1)
         {
            rewards = [rewards[1],numRewards > 2 ? rewards[2] : null,rewards[0]];
            numRewards = 3;
         }
         for(var index:int = 0; index < numRewards; index++)
         {
            rewardCountString = "rewardCount_" + index + "_tf";
            rewardIconString = "rewardIcon_" + index + "_mc";
            if(Boolean(m_element[rewardCountString]) && Boolean(m_element[rewardIconString]) && Boolean(rewards[index]))
            {
               type = rewards[index]["type"];
               value = rewards[index]["value"];
               switch(type)
               {
                  case "xp":
                     icon = new FarmIcon(m_element[rewardIconString],"assets/decorations/fv_xp_icon.png");
                     icon.attachTooltip(new FarmTextTooltip(ZLocUtils.t("Dialogs","GopherGarden_TrapperRewardXP_tooltip",{"count":value})));
                     m_element[rewardCountString].visible = true;
                     m_element[rewardCountString].text = value;
                     break;
                  case "coins":
                     icon = new FarmIcon(m_element[rewardIconString],"assets/decorations/fv_coin_icon.png");
                     icon.attachTooltip(new FarmTextTooltip(ZLocUtils.t("Dialogs","GopherGarden_TrapperRewardCoins_tooltip",{"count":value})));
                     m_element[rewardCountString].visible = true;
                     m_element[rewardCountString].text = value;
                     break;
                  case "item_grant":
                     item = Global.farmGameSettingsManager.getFarmItemByCode(value);
                     if(item)
                     {
                        icon = new FarmIcon(m_element[rewardIconString],item.iconUrl);
                        icon.attachTooltip(new FarmTextTooltip(item.friendlyTitle));
                     }
               }
               icon.setIconSize(iconWidth,iconHeight);
               addWidget(icon,true);
            }
         }
      }
   }
}

