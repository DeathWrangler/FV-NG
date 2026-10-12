package Widgets.Windows
{
   import Classes.ZItem.FarmItem;
   import Managers.OctoberSidecarFeatureManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class OctoberSidecarFeatureCollectionsWindow extends FarmWindowWithTutorial
   {
      
      private static const FEATURE_NAME:String = "GilroysParade";
      
      public static const COLLECTIONS_FTUE_SEEN_FLAG:String = FEATURE_NAME + "_collections_ftue_seen";
      
      private var m_featureName:String = null;
      
      private const NUM_STAGE_REWARDS:int = 5;
      
      private var m_collections_mc:MovieClip;
      
      private var m_rewardpack_mc:MovieClip;
      
      private var m_rewardpanel_mc:MovieClip;
      
      private var m_stolen_items:Array = [];
      
      private var m_reward_icons:Array = [];
      
      private var m_checkmark_icons:Array = [];
      
      private var m_ftue_mc:MovieClip;
      
      private var m_ftue_button:FarmAnimatedTextButton;
      
      public function OctoberSidecarFeatureCollectionsWindow(featureName:String = "GilroysParade", assetUrl:String = null)
      {
         this.m_featureName = featureName;
         super(FEATURE_NAME,assetUrl);
      }
      
      override protected function postLoadComplete() : void
      {
         var index:int = 0;
         var itemIndex:String = null;
         var rewardIndex:String = null;
         var checkmarkIndex:String = null;
         super.postLoadComplete();
         this.setWindowPosition();
         if(m_window.hasOwnProperty("title_tf"))
         {
            addWidget(new ZwTextField(m_window["title_tf"],"STOLEN ITEMS"));
         }
         if(m_window.hasOwnProperty("tutorial1_mc"))
         {
            this.m_ftue_mc = m_window["tutorial1_mc"] as MovieClip;
            this.m_ftue_mc.visible = false;
            if(this.m_ftue_mc.hasOwnProperty("okay1_bt"))
            {
               this.m_ftue_button = new FarmAnimatedTextButton(this.m_ftue_mc["okay1_bt"],"Interesting!",this.onTutorialButtonClick);
            }
         }
         if(m_window.hasOwnProperty("body_tf"))
         {
            if(this.manager.isFeatureCompletedByUser())
            {
               addWidget(new ZwTextField(m_window["body_tf"],"Congrats! All stolen items have been found!"));
            }
            else
            {
               addWidget(new ZwTextField(m_window["body_tf"],"Find all the stolen items to solve this mystery and win a special reward"));
            }
         }
         if(m_window.hasOwnProperty("collections_mc"))
         {
            this.m_collections_mc = m_window["collections_mc"] as MovieClip;
            for(index = 0; index < this.manager.NUM_TOTAL_ITEMS; index++)
            {
               itemIndex = "antique" + index + "_mc";
               if(this.m_collections_mc.hasOwnProperty(itemIndex))
               {
                  this.m_stolen_items[index] = this.m_collections_mc[itemIndex] as MovieClip;
                  this.populateItemForIndex(index);
               }
            }
            this.m_collections_mc.visible = true;
         }
         if(m_window.hasOwnProperty("reward_pack"))
         {
            this.m_rewardpack_mc = m_window["reward_pack"] as MovieClip;
            this.m_rewardpack_mc.visible = true;
         }
         if(m_window.hasOwnProperty("reward_panel"))
         {
            this.m_rewardpanel_mc = m_window["reward_panel"] as MovieClip;
            for(index = 0; index < this.NUM_STAGE_REWARDS; index++)
            {
               rewardIndex = "reward_" + index;
               if(this.m_rewardpanel_mc.hasOwnProperty(rewardIndex))
               {
                  this.m_reward_icons[index] = this.m_rewardpanel_mc[rewardIndex] as MovieClip;
                  if(this.m_reward_icons[index].hasOwnProperty("rewardbrief_tf"))
                  {
                     this.m_reward_icons[index]["rewardbrief_tf"].text = "Find " + this.manager.m_milestonePoints[index] + " items";
                     this.m_reward_icons[index]["rewardbrief_tf"].visible = true;
                  }
                  this.m_reward_icons[index].visible = true;
               }
               checkmarkIndex = "checkmark_" + index + "_mc";
               if(this.m_rewardpanel_mc.hasOwnProperty(checkmarkIndex))
               {
                  this.m_checkmark_icons[index] = this.m_rewardpanel_mc[checkmarkIndex] as MovieClip;
                  this.m_checkmark_icons[index].visible = this.manager.isItemComplete(this.manager.m_milestonePoints[index] - 1);
               }
            }
            this.m_rewardpanel_mc.visible = true;
         }
         if(!Global.player.getSeenFlag(COLLECTIONS_FTUE_SEEN_FLAG))
         {
            if(this.m_ftue_mc)
            {
               this.m_ftue_mc.visible = true;
            }
         }
      }
      
      private function onTutorialButtonClick(e:Event = null) : void
      {
         if(Boolean(this.manager.m_mainWindow) && !Global.player.getSeenFlag(COLLECTIONS_FTUE_SEEN_FLAG))
         {
            this.manager.m_mainWindow.playFirstTimeTutorial(3);
            Global.player.setSeenFlag(COLLECTIONS_FTUE_SEEN_FLAG);
         }
         this.close();
      }
      
      private function populateItemForIndex(index:int) : void
      {
         var stageIconUrl:String = null;
         var itemIcon:FarmIcon = null;
         var stageItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.manager.m_stolenItems[index]);
         if(this.m_stolen_items[index].hasOwnProperty("antique_icon"))
         {
            stageIconUrl = this.manager.PREFIX_STAGE_ICON_PATH + this.manager.m_stolenItems[index] + "_stage" + this.manager.NUM_STAGES_PER_ITEM + this.manager.SUFFIX_STAGE_ICON_PATH;
            itemIcon = new FarmIcon(this.m_stolen_items[index]["antique_icon"],stageIconUrl);
            itemIcon.setIconSize(80,80);
            itemIcon.visible = true;
         }
         if(Boolean(this.m_stolen_items[index].hasOwnProperty("antiquename_tf")) && Boolean(stageItem))
         {
            this.m_stolen_items[index]["antiquename_tf"].text = stageItem.friendlyTitle;
            this.m_stolen_items[index]["antiquename_tf"].visible = true;
         }
         if(this.m_stolen_items[index].hasOwnProperty("check_mc"))
         {
            this.m_stolen_items[index]["check_mc"].visible = this.manager.isItemComplete(index) ? true : false;
         }
         if(this.m_stolen_items[index].hasOwnProperty("current_highlight_mc"))
         {
            this.m_stolen_items[index]["current_highlight_mc"].visible = this.manager.isItemActive(index) ? true : false;
         }
         this.m_stolen_items[index].visible = true;
      }
      
      private function setWindowPosition() : void
      {
         if(m_window)
         {
            m_window.x += 55;
         }
      }
      
      private function get manager() : OctoberSidecarFeatureManager
      {
         return OctoberSidecarFeatureManager.getInstance(FEATURE_NAME);
      }
      
      override public function close() : void
      {
         if(Boolean(this.manager.m_mainWindow) && !Global.player.getSeenFlag(COLLECTIONS_FTUE_SEEN_FLAG))
         {
            this.manager.m_mainWindow.playFirstTimeTutorial(3);
            Global.player.setSeenFlag(COLLECTIONS_FTUE_SEEN_FLAG);
         }
         if(this.manager.m_mainWindow)
         {
            this.manager.m_mainWindow.enableInput = true;
            this.manager.m_mainWindow.untintWindow();
         }
         super.close();
      }
   }
}

