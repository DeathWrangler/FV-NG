package Widgets.Windows
{
   import Classes.Quest.FarmTask;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Engine.Managers.StatsManager;
   import Managers.AnimalSanctuaryV2Manager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.AnimalSanctuaryV2CraftTasksFrame;
   import Widgets.Frames.AnimalSanctuaryV2PlantTasksFrame;
   import Widgets.Icons.FarmIcon;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class AnimalSanctuaryV2TasksWindow extends FarmWindowWithTutorial
   {
      
      private var m_featureName:String;
      
      private var m_craft_tasks_frame:AnimalSanctuaryV2CraftTasksFrame;
      
      private var m_plant_tasks_frame:AnimalSanctuaryV2PlantTasksFrame;
      
      private var m_viral_task_mc:MovieClip;
      
      private var m_taskBt:FarmAnimatedTextButton;
      
      private var m_allCurrencyAarray:Array = [];
      
      private var m_task:FarmTask;
      
      private var m_travelBt:FarmAnimatedTextButton;
      
      private var travel_mc:MovieClip;
      
      private var craft_mc:MovieClip;
      
      private var plant_mc:MovieClip;
      
      private var m_overlaySubtext1:ZwTextField;
      
      private var m_overlaySubtext2:ZwTextField;
      
      private var m_viralCount:ZwTextField;
      
      private var m_ftue:MovieClip;
      
      private var m_ftueOk:FarmAnimatedTextButton;
      
      private const ANIMAL_SANCTUARY_V2_TASK_FTUE_FLAG:String = "as_v2_task_ftue_flag";
      
      private var m_whatIsThisBt:FarmAnimatedTextButton;
      
      public function AnimalSanctuaryV2TasksWindow(featureName:String, assetPath:String)
      {
         this.m_featureName = featureName;
         super(featureName,assetPath);
      }
      
      private static function toggleButton(button:FarmAnimatedTextButton, to:Boolean) : void
      {
         button.enabled = to;
         button.applyGrayOut = !to;
      }
      
      override protected function postLoadComplete() : void
      {
         var m_allCurrencyInfoMc:MovieClip = null;
         var index:int = 0;
         var allCurrencydata:Array = null;
         var currencyIterator:int = 0;
         var currencyMc:MovieClip = null;
         var tooltipText:String = null;
         super.postLoadComplete();
         if(m_window.hasOwnProperty("subtext_tf"))
         {
            addWidget(new ZwTextField(m_window["subtext_tf"],"Get coupon drops by doing tasks on " + this.manager.VAL_FARM_NAMES_ARRAY[this.manager.getWorldId()]));
         }
         if(m_window.hasOwnProperty("all_craft_item_mc"))
         {
            this.craft_mc = m_window["all_craft_item_mc"] as MovieClip;
            this.m_craft_tasks_frame = new AnimalSanctuaryV2CraftTasksFrame(this.m_featureName,m_window["all_craft_item_mc"]);
            this.m_craft_tasks_frame.visible = true;
            this.craft_mc.visible = true;
         }
         if(m_window.hasOwnProperty("all_plant_item_mc"))
         {
            this.plant_mc = m_window["all_plant_item_mc"] as MovieClip;
            this.m_plant_tasks_frame = new AnimalSanctuaryV2PlantTasksFrame(this.m_featureName,m_window["all_plant_item_mc"]);
            this.m_plant_tasks_frame.visible = true;
            this.plant_mc.visible = true;
         }
         if(m_window.hasOwnProperty("ftue_mc"))
         {
            this.m_ftue = m_window["ftue_mc"] as MovieClip;
            this.m_ftue.visible = false;
            if(this.m_ftue.hasOwnProperty("okay_bt"))
            {
               this.m_ftueOk = new FarmAnimatedTextButton(this.m_ftue["okay_bt"],"OK!",this.onFTUE);
               this.m_ftueOk.visible = false;
            }
         }
         if(m_window.hasOwnProperty("howDoesThisWork_mc"))
         {
            addWidget(this.m_whatIsThisBt = new FarmAnimatedTextButton(m_window["howDoesThisWork_mc"],"",this.onHowDoesThisWorkClick));
            this.m_whatIsThisBt.visible = false;
         }
         if(m_window.hasOwnProperty("all_currency_info_mc"))
         {
            m_allCurrencyInfoMc = m_window["all_currency_info_mc"] as MovieClip;
            m_allCurrencyInfoMc.visible = true;
            for(index = 0; index < 3; index++)
            {
               if(m_allCurrencyInfoMc.hasOwnProperty("currency_" + index + "_info_mc"))
               {
                  allCurrencydata = new Array();
                  currencyIterator = 0;
                  currencyMc = m_allCurrencyInfoMc["currency_" + index + "_info_mc"] as MovieClip;
                  if(currencyMc.hasOwnProperty("currency_count_tf"))
                  {
                     allCurrencydata[currencyIterator] = new ZwTextField(currencyMc["currency_count_tf"],"64");
                     currencyIterator++;
                  }
                  if(currencyMc.hasOwnProperty("currency_name_tf"))
                  {
                     allCurrencydata[currencyIterator] = new ZwTextField(currencyMc["currency_name_tf"],this.manager.VAL_COUPON_NAME_TYPE[index]);
                     currencyIterator++;
                  }
                  if(currencyMc.hasOwnProperty("currency_icon_mc"))
                  {
                     allCurrencydata[currencyIterator] = new FarmIcon(currencyMc["currency_icon_mc"]);
                     if(index == 0)
                     {
                        allCurrencydata[currencyIterator].loadIcon(Global.getAssetURL(this.manager.ASSET_PATH + this.manager.ANIMAL_COUPONS_FOOD_IMAGES[this.manager.getAnimalId()] + "_icon_35.png"));
                     }
                     else if(index == 1)
                     {
                        allCurrencydata[currencyIterator].loadIcon(Global.getAssetURL(this.manager.ASSET_PATH + this.manager.ANIMAL_COUPONS_HEALTH_IMAGES[this.manager.getAnimalId()] + "_icon_35.png"));
                     }
                     else
                     {
                        allCurrencydata[currencyIterator].loadIcon(Global.getAssetURL(this.manager.ASSET_PATH + this.manager.ANIMAL_COUPONS_HABITAT_IMAGES[this.manager.getAnimalId()] + "_icon_35.png"));
                     }
                     allCurrencydata[currencyIterator].setIconSize(35,35);
                     allCurrencydata[currencyIterator].visible = true;
                     currencyIterator++;
                  }
                  this.m_allCurrencyAarray[index] = allCurrencydata;
               }
            }
         }
         this.refreshCouponsCount();
         if(m_window.hasOwnProperty("travel_overlay_mc"))
         {
            this.travel_mc = m_window["travel_overlay_mc"] as MovieClip;
            this.travel_mc.visible = false;
            if(this.travel_mc.hasOwnProperty("travel_okay_bt"))
            {
               addWidget(this.m_travelBt = new FarmAnimatedTextButton(m_window["travel_overlay_mc"]["travel_okay_bt"],"Travel",this.onTravelWorld));
            }
            if(this.travel_mc.hasOwnProperty("overlay_subtext_1_tf"))
            {
               addWidget(this.m_overlaySubtext1 = new ZwTextField(this.travel_mc["overlay_subtext_1_tf"],"Get coupon drops by doing tasks on " + this.manager.VAL_FARM_NAMES_ARRAY[this.manager.getWorldId()]));
               this.m_overlaySubtext1.visible = false;
            }
            if(this.travel_mc.hasOwnProperty("overlay_subtext_2_tf"))
            {
               addWidget(this.m_overlaySubtext2 = new ZwTextField(this.travel_mc["overlay_subtext_2_tf"],"It seems like you’re on a different farm! Travel to " + this.manager.VAL_FARM_NAMES_ARRAY[this.manager.getWorldId()] + " to do these tasks!"));
            }
         }
         if(m_window.hasOwnProperty("viral_task_mc"))
         {
            this.m_viral_task_mc = m_window["viral_task_mc"] as MovieClip;
            this.m_viral_task_mc.visible = true;
            if(this.m_viral_task_mc.hasOwnProperty("viral_count_tf"))
            {
               addWidget(this.m_viralCount = new ZwTextField(this.m_viral_task_mc["viral_count_tf"],""));
            }
            if(this.m_viral_task_mc.hasOwnProperty("okay_bt"))
            {
               this.m_taskBt = new FarmAnimatedTextButton(this.m_viral_task_mc["okay_bt"],"Ask",this.onAsk);
               this.m_taskBt.visible = true;
               this.m_task = this.manager.getViralTask();
               this.m_taskBt.enabled = this.m_task.canAskForHelp();
               this.m_taskBt.detachTooltip();
               if(!this.m_taskBt.enabled && Boolean(this.m_task))
               {
                  tooltipText = this.m_task.helperText;
                  this.m_taskBt.callback = null;
                  FarmGameUtil.disableButtonAndShowTooltip(this.m_taskBt,tooltipText);
               }
               else
               {
                  toggleButton(this.m_taskBt,true);
               }
            }
            if(Boolean(this.m_viralCount) && Boolean(this.m_task))
            {
               this.m_viralCount.text = "Collect " + (10 - this.manager.getViralProgress(this.m_task.type)).toString() + "\n Fresh Water Buckets to get a coupon drop!";
               this.m_viralCount.visible = true;
            }
         }
         if(this.manager.getSelectedWorld() != Global.worldManager.currentWorldType)
         {
            this.travel_mc.visible = true;
            if(Boolean(this.craft_mc) && Boolean(this.plant_mc))
            {
               this.craft_mc.visible = false;
               this.plant_mc.visible = false;
            }
         }
      }
      
      private function get manager() : AnimalSanctuaryV2Manager
      {
         return AnimalSanctuaryV2Manager.getInstance();
      }
      
      public function refreshCouponsCount() : void
      {
         for(var i:int = 0; i < 3; i++)
         {
            if(Boolean(this.m_allCurrencyAarray) && Boolean(this.m_allCurrencyAarray[i]))
            {
               this.m_allCurrencyAarray[i][0].text = "x" + this.manager.consumableCount(i).toString();
            }
         }
      }
      
      public function showTutorial1() : void
      {
         if(this.m_ftue)
         {
            this.m_ftue.visible = true;
         }
      }
      
      public function onAsk(e:Event) : void
      {
         this.m_task.performHelperAction(null,this.onAskFeedPosted);
         this.m_taskBt.enabled = false;
      }
      
      public function onFTUE(e:Event) : void
      {
         if(this.m_ftue)
         {
            this.m_ftue.visible = false;
         }
      }
      
      private function onHowDoesThisWorkClick(event:Event) : void
      {
         if(this.m_ftue)
         {
            this.m_ftue.visible = true;
         }
      }
      
      private function onAskFeedPosted(success:Boolean) : void
      {
         var task:FarmTask = this.m_task;
         if(Boolean(this.m_taskBt) && Boolean(task) && success)
         {
            if(task.canAskForHelp())
            {
               this.m_taskBt.enabled = true;
            }
            else
            {
               this.m_taskBt.enabled = false;
               this.m_taskBt.text = ZLocUtils.t("Quests","Helper_AskForHelp_Sent");
               this.m_taskBt.callback = null;
               FarmGameUtil.disableButtonAndShowTooltip(this.m_taskBt,task.helperText);
               StatsManager.count("AnimalSanctuaryV2","select","task","viral","freshwaterbucket");
            }
         }
      }
      
      public function onTravelWorld(event:Event) : void
      {
         this.manager.onTravelButtonClick();
         this.close();
      }
      
      override public function close() : void
      {
         if(this.manager.mainWindow)
         {
            this.manager.mainWindow.untintWindow();
            this.manager.mainWindow.enableInput = true;
         }
         super.close();
      }
   }
}

