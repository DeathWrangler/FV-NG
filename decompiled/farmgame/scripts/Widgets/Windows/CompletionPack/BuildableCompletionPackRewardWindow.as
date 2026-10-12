package Widgets.Windows.CompletionPack
{
   import Classes.util.ZLocUtils;
   import Managers.BuildableCompletionPackagesManager;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.FarmWindow;
   import flash.events.MouseEvent;
   
   public class BuildableCompletionPackRewardWindow extends FarmWindow
   {
      
      private static const XAU_COMPLETION_PACK_REWARD_WINDOW_ASSET:String = "assets/dialogs/xau_completionPack_reward.swf";
      
      private static const COMPLETION_PACK_REWARD_WINDOW_ASSET:String = "assets/dialogs/Candy/FV_xcw_completionPack_reward.swf";
      
      private var m_isInCompletionPackWorld:Boolean = false;
      
      private var m_completedText:String = "";
      
      private var m_packageIcon:String = "";
      
      private var m_optionName:String = "";
      
      private var m_rewardNames:Array = null;
      
      public function BuildableCompletionPackRewardWindow(optionName:String, isInCompletionPackWorld:Boolean, completedText:String, packageIcon:String, rewardNames:Array)
      {
         this.m_isInCompletionPackWorld = isInCompletionPackWorld;
         this.m_completedText = completedText;
         this.m_packageIcon = packageIcon;
         this.m_optionName = optionName;
         this.m_rewardNames = rewardNames;
         FarmStatsManager.count("Reward_Dialog","impressions",BuildableCompletionPackagesManager.REWARD_DIALOG_STAT);
         super(COMPLETION_PACK_REWARD_WINDOW_ASSET);
      }
      
      override protected function postLoadComplete() : void
      {
         var rewardsLength:int = 0;
         var icon:FarmIcon = null;
         var infoText:String = null;
         var rewardsString:String = null;
         var i:int = 0;
         var text:String = null;
         super.postLoadComplete();
         if(m_window)
         {
            if(m_window.hasOwnProperty("title_tf"))
            {
               addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs","completion_pack_reward_dialog_title")));
            }
            if(m_window.hasOwnProperty("text_tf"))
            {
               addWidget(new ZwTextField(m_window.text_tf,ZLocUtils.t("Dialogs","completion_pack_reward_dialog_subtext",{"buildings":this.m_completedText})));
            }
            if(m_window.hasOwnProperty("subText_tf") && this.m_optionName == BuildableCompletionPackagesManager.OPTION_4)
            {
               addWidget(new ZwTextField(m_window.subText_tf,ZLocUtils.t("Dialogs","completion_pack_reward_dialog_sidetext")));
            }
            if(m_window.hasOwnProperty("icon_mc"))
            {
               icon = addWidget(new FarmIcon(m_window.icon_mc,this.m_packageIcon)) as FarmIcon;
               icon.visible = true;
            }
            rewardsLength = int(this.m_rewardNames.length);
            if(m_window.hasOwnProperty("info_tf") && rewardsLength > 0)
            {
               infoText = "";
               if(rewardsLength != 1)
               {
                  rewardsString = this.m_rewardNames[0];
                  for(i = 1; i < rewardsLength; i++)
                  {
                     rewardsString += ", " + this.m_rewardNames[i];
                  }
                  infoText = ZLocUtils.t("Dialogs","completion_pack_reward_dialog_info",{"items":rewardsString});
               }
               else
               {
                  infoText = ZLocUtils.t("Dialogs","completion_pack_reward_dialog_info_single",{"item":this.m_rewardNames[0].toString()});
               }
               addWidget(new ZwTextField(m_window.info_tf,infoText));
            }
            if(m_window.hasOwnProperty("accept_bt"))
            {
               text = "";
               if(this.m_isInCompletionPackWorld)
               {
                  text = ZLocUtils.t("Dialogs","Awesome");
               }
               else
               {
                  text = ZLocUtils.t("Dialogs","completion_pack_reward_dialog_button");
               }
               addWidget(new FarmAnimatedTextButton(m_window.accept_bt,text,this.onAccept));
            }
         }
      }
      
      private function onAccept(event:MouseEvent) : void
      {
         FarmStatsManager.count("Reward_Dialog","clicks",BuildableCompletionPackagesManager.REWARD_DIALOG_STAT);
         close();
         if(!this.m_isInCompletionPackWorld)
         {
            BuildableCompletionPackagesManager.getInstance().travelToBuildablesCompletionPackWorld();
         }
      }
   }
}

