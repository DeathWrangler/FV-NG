package Widgets.Windows
{
   import Classes.ZItem.FarmItem;
   import Display.HUD.HUD;
   import Engine.Managers.StatsManager;
   import Managers.AnimalSanctuaryV2Manager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class AnimalSanctuaryV2MainWindow extends FarmWindowWithTutorial
   {
      
      private static const NUM_TUTORIAL_SCENES:int = 0;
      
      private static const NUM_OF_CURRENCIES:int = 1;
      
      private static const NUM_OF_STATS:int = 3;
      
      private static const NUM_OF_ANIMALS:int = 4;
      
      private static const NUM_OF_CONSUMABLES_NEEDED_TO_SINK:int = 10;
      
      private static const LENGTH_STATS_PROGRESS_BAR:int = 160;
      
      private var m_featureName:String;
      
      private var m_all_currency_mc:MovieClip;
      
      private var m_buy_bt:FarmAnimatedTextButton;
      
      private var m_earn_bt:FarmAnimatedTextButton;
      
      private var m_currency_mc:MovieClip;
      
      private var m_all_stats_mc:MovieClip;
      
      private var m_stat_infos_mc:Array = [];
      
      private var m_info_btn_mc:Array = [];
      
      public var m_stat_progresses_bt:Array = [];
      
      private var m_stat_meters_mc:Array = [];
      
      private var m_stat_bar_fills_mc:Array = [];
      
      private var m_stat_conditions_mc:Array = [];
      
      private var m_stat_tooltips_mc:Array = [];
      
      private var m_stat_condition_timers_tf:Array = [];
      
      public var m_stat_conditions_bt:Array = [];
      
      private var m_stat_progresses_tf:Array = [];
      
      private var m_animal_sanctuary_mc:FarmIcon;
      
      private var m_current_animal_data_mc:MovieClip;
      
      private var m_current_animal_icon_mc:FarmIcon;
      
      private var m_current_animal_name_tf:ZwTextField;
      
      private var m_other_animals_data_mc:MovieClip;
      
      private var m_other_animals_mc:Array = [];
      
      private var m_other_animal_icons_mc:Array = [];
      
      private var m_other_animal_names_tf:Array = [];
      
      private var m_stage_counter_mc:MovieClip;
      
      private var m_milestone_icon_mc:FarmIcon;
      
      private var m_stage_meter_mc:MovieClip;
      
      private var m_stage_bar_fill_mc:MovieClip;
      
      private var m_stage_count_tf:ZwTextField;
      
      private var m_animal_title_tf:ZwTextField;
      
      private var m_farm_title_tf:ZwTextField;
      
      private var m_feature_timer_tf:ZwTextField;
      
      private var m_howDoesThisWork_mc:MovieClip;
      
      private var m_unicorn_sanctuary_mc:MovieClip;
      
      private var m_view_rewards_bt:FarmAnimatedTextButton;
      
      private var m_ftue_mc:MovieClip;
      
      private var m_allCurrencyAarray:Array = [];
      
      private var m_skip_timers:Array = [];
      
      private var m_tutorialButtons:Array = [];
      
      private const ANIMAL_SANCTUARY_MAIN_FTUE_FLAG:String = "as_v2_main_ftue_flag";
      
      private var m_tutorialMc:MovieClip;
      
      public var m_animalCalloutMc:MovieClip;
      
      private var m_animalCallout_tf:ZwTextField;
      
      private var m_milestoneHoverMc:MovieClip;
      
      private var m_milestoneItem:FarmIcon;
      
      private var m_consumable1:FarmIcon;
      
      private var m_consumable2:FarmIcon;
      
      private var m_milestoneRewardName_tf:ZwTextField;
      
      private var m_milestoneFlavor_tf:ZwTextField;
      
      private var m_whatIsThisBt:FarmAnimatedTextButton;
      
      private var m_tutorialMiniMc:MovieClip;
      
      private var m_minitutorial_frame:ZwFrame;
      
      private var m_tutorialMiniButtons:Array = [];
      
      private var m_tutorialMiniPerMc:MovieClip;
      
      private var m_timerNPC5:Timer = null;
      
      private var m_timer:Timer;
      
      public function AnimalSanctuaryV2MainWindow(featureName:String, assetPath:String, showEAPageTutorial:Boolean = false)
      {
         this.m_featureName = featureName;
         var numOfTutorialPages:int = 0;
         super(this.m_featureName,assetPath,numOfTutorialPages);
      }
      
      override protected function postLoadComplete() : void
      {
         var index:int = 0;
         var allCurrencydata:Array = null;
         var currencyIterator:int = 0;
         var currencyMc:MovieClip = null;
         var i:int = 0;
         var m_stat_info_mc:MovieClip = null;
         var m_stat_progress_bt:FarmAnimatedTextButton = null;
         var m_stat_meter_mc:MovieClip = null;
         var m_stat_bar_fill_mc:MovieClip = null;
         var m_stat_condition_mc:MovieClip = null;
         var m_stat_tooltip_mc:ZwFrame = null;
         var m_stat_condition_timer_tf:ZwTextField = null;
         var m_stat_condition_bt:FarmAnimatedTextButton = null;
         var m_stat_progress_tf:ZwTextField = null;
         var m_token_icon:FarmIcon = null;
         var m_token_buy_icon:FarmIcon = null;
         var info_btn_mc:ZwButton = null;
         var conditionElementName:String = null;
         var currentAnimalData:Object = null;
         var otherAnimalsData:Array = null;
         var m_other_animal_mc:MovieClip = null;
         var m_other_animal_icon_mc:FarmIcon = null;
         var m_other_animal_name_tf:ZwTextField = null;
         var featureEndsInText:String = null;
         var j:int = 0;
         var buttonName1:String = null;
         super.postLoadComplete();
         if(m_window.hasOwnProperty("all_currency_mc"))
         {
            this.m_all_currency_mc = m_window["all_currency_mc"] as MovieClip;
            this.m_all_currency_mc.visible = true;
            if(this.m_all_currency_mc.hasOwnProperty("buy_bt"))
            {
               this.m_buy_bt = new FarmAnimatedTextButton(this.m_all_currency_mc["buy_bt"],"FC buy!",this.buyCouponsClick);
               this.m_buy_bt.visible = true;
            }
            if(this.m_all_currency_mc.hasOwnProperty("earn_bt"))
            {
               this.m_earn_bt = new FarmAnimatedTextButton(this.m_all_currency_mc["earn_bt"],"Earn More!",this.onClickEarnButton);
               this.m_earn_bt.visible = true;
            }
            for(index = 0; index < 3; index++)
            {
               if(this.m_all_currency_mc.hasOwnProperty("currency_" + index + "_mc"))
               {
                  allCurrencydata = new Array();
                  currencyIterator = 0;
                  currencyMc = this.m_all_currency_mc["currency_" + index + "_mc"] as MovieClip;
                  if(currencyMc.hasOwnProperty("c_count_tf"))
                  {
                     allCurrencydata[currencyIterator] = new ZwTextField(currencyMc["c_count_tf"],"");
                     currencyIterator++;
                  }
                  if(currencyMc.hasOwnProperty("c_coin_mc"))
                  {
                     allCurrencydata[currencyIterator] = new FarmIcon(currencyMc["c_coin_mc"]);
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
         if(m_window.hasOwnProperty("all_stats_mc"))
         {
            this.m_all_stats_mc = m_window["all_stats_mc"] as MovieClip;
            this.m_all_stats_mc.visible = true;
            for(i = 0; i < NUM_OF_STATS; i++)
            {
               if(this.m_all_stats_mc.hasOwnProperty("stat_info_" + i + "_mc"))
               {
                  m_stat_info_mc = this.m_all_stats_mc["stat_info_" + i + "_mc"] as MovieClip;
                  if(m_stat_info_mc.hasOwnProperty("stat_" + i + "_progress_bt"))
                  {
                     m_stat_progress_bt = new FarmAnimatedTextButton(m_stat_info_mc["stat_" + i + "_progress_bt"],"stat_" + i + "_progress_bt");
                     if(m_stat_progress_bt.element.hasOwnProperty("token_icon_mc"))
                     {
                        m_token_icon = new FarmIcon(m_stat_progress_bt.element["token_icon_mc"]);
                        m_token_icon.visible = true;
                        if(i == 0)
                        {
                           m_token_icon.loadIcon(Global.getAssetURL(this.manager.ASSET_PATH + this.manager.ANIMAL_COUPONS_FOOD_IMAGES[this.manager.getAnimalId()] + "_icon_35.png"));
                        }
                        else if(i == 1)
                        {
                           m_token_icon.loadIcon(Global.getAssetURL(this.manager.ASSET_PATH + this.manager.ANIMAL_COUPONS_HEALTH_IMAGES[this.manager.getAnimalId()] + "_icon_35.png"));
                        }
                        else
                        {
                           m_token_icon.loadIcon(Global.getAssetURL(this.manager.ASSET_PATH + this.manager.ANIMAL_COUPONS_HABITAT_IMAGES[this.manager.getAnimalId()] + "_icon_35.png"));
                        }
                     }
                  }
                  if(m_stat_info_mc.hasOwnProperty("stat_meter_mc"))
                  {
                     m_stat_meter_mc = m_stat_info_mc["stat_meter_mc"] as MovieClip;
                     if(m_stat_meter_mc.hasOwnProperty("bar_fill_mc"))
                     {
                        m_stat_bar_fill_mc = m_stat_meter_mc["bar_fill_mc"] as MovieClip;
                     }
                  }
                  conditionElementName = "condition_" + i + "_mc";
                  if(m_stat_info_mc.hasOwnProperty(conditionElementName))
                  {
                     m_stat_condition_mc = m_stat_info_mc[conditionElementName] as MovieClip;
                     if(m_stat_condition_mc.hasOwnProperty("condition_timer_tf"))
                     {
                        m_stat_condition_timer_tf = new ZwTextField(m_stat_condition_mc["condition_timer_tf"],"timer");
                     }
                     if(m_stat_condition_mc.hasOwnProperty("stat_" + i + "_condition_bt"))
                     {
                        m_stat_condition_bt = new FarmAnimatedTextButton(m_stat_condition_mc["stat_" + i + "_condition_bt"],"stat_" + i + "_condition_bt");
                     }
                     if(m_stat_condition_bt.element.hasOwnProperty("token_icon_mc"))
                     {
                        m_token_buy_icon = new FarmIcon(m_stat_condition_bt.element["token_icon_mc"]);
                        m_token_buy_icon.visible = true;
                        if(i == 0)
                        {
                           m_token_buy_icon.loadIcon(Global.getAssetURL(this.manager.ASSET_PATH + this.manager.ANIMAL_COUPONS_FOOD_IMAGES[this.manager.getAnimalId()] + "_icon_35.png"));
                        }
                        else if(i == 1)
                        {
                           m_token_buy_icon.loadIcon(Global.getAssetURL(this.manager.ASSET_PATH + this.manager.ANIMAL_COUPONS_HEALTH_IMAGES[this.manager.getAnimalId()] + "_icon_35.png"));
                        }
                        else
                        {
                           m_token_buy_icon.loadIcon(Global.getAssetURL(this.manager.ASSET_PATH + this.manager.ANIMAL_COUPONS_HABITAT_IMAGES[this.manager.getAnimalId()] + "_icon_35.png"));
                        }
                     }
                  }
                  if(m_stat_info_mc.hasOwnProperty("stat_progress_tf"))
                  {
                     m_stat_progress_tf = new ZwTextField(m_stat_info_mc["stat_progress_tf"],"stat_" + i + "_progress_tf");
                  }
                  if(m_stat_info_mc.hasOwnProperty("info_btn_mc"))
                  {
                     info_btn_mc = new ZwButton(m_stat_info_mc["info_btn_mc"]) as ZwButton;
                  }
               }
               this.m_info_btn_mc.push(info_btn_mc);
               if(this.m_info_btn_mc[i])
               {
                  this.m_info_btn_mc[i].visible = true;
                  this.m_info_btn_mc[i].attachTooltip(new FarmTextTooltip(this.getTootltipTextForResource(i)));
               }
               this.m_stat_infos_mc.push(m_stat_info_mc);
               if(this.m_stat_infos_mc[i])
               {
                  this.m_stat_infos_mc[i].visible = true;
               }
               this.m_stat_progresses_bt.push(m_stat_progress_bt);
               if(this.m_stat_progresses_bt[i])
               {
                  this.m_stat_progresses_bt[i].text = "10 Use";
                  this.m_stat_progresses_bt[i].callback = this.onSinkClick(i);
                  this.m_stat_progresses_bt[i].visible = true;
               }
               this.m_stat_meters_mc.push(m_stat_meter_mc);
               if(this.m_stat_meters_mc[i])
               {
                  this.m_stat_meters_mc[i].visible = true;
               }
               this.m_stat_bar_fills_mc.push(m_stat_bar_fill_mc);
               if(this.m_stat_bar_fills_mc[i])
               {
                  this.m_stat_bar_fills_mc[i].visible = true;
               }
               this.m_stat_conditions_mc.push(m_stat_condition_mc);
               if(this.m_stat_conditions_mc[i])
               {
                  this.m_stat_conditions_mc[i].visible = true;
               }
               this.m_stat_condition_timers_tf.push(m_stat_condition_timer_tf);
               if(this.m_stat_condition_timers_tf[i])
               {
                  this.m_stat_condition_timers_tf[i].visible = false;
               }
               this.m_stat_conditions_bt.push(m_stat_condition_bt);
               if(this.m_stat_conditions_bt[i])
               {
                  this.m_stat_conditions_bt[i].text = "30 Fix!";
                  this.m_stat_conditions_bt[i].callback = this.onStarvSinkClick(i);
                  this.m_stat_conditions_bt[i].visible = false;
               }
               this.m_stat_progresses_tf.push(m_stat_progress_tf);
               if(this.m_stat_progresses_tf[i])
               {
                  this.m_stat_progresses_tf[i].visible = true;
               }
            }
         }
         if(m_window.hasOwnProperty("animal_sanctuary_mc"))
         {
            this.m_animal_sanctuary_mc = new FarmIcon(m_window["animal_sanctuary_mc"]);
            this.m_animal_sanctuary_mc.visible = true;
         }
         if(m_window.hasOwnProperty("animal_title_tf"))
         {
            currentAnimalData = this.manager.getSelectedAnimalData();
            this.m_animal_title_tf = new ZwTextField(m_window["animal_title_tf"],currentAnimalData.friendlyTitle);
            this.m_animal_title_tf.visible = true;
         }
         if(m_window.hasOwnProperty("current_animal_mc"))
         {
            this.m_current_animal_data_mc = m_window["current_animal_mc"] as MovieClip;
            this.m_current_animal_data_mc.visible = true;
            if(this.m_current_animal_data_mc.hasOwnProperty("current_animal_icon_mc"))
            {
               this.m_current_animal_icon_mc = new FarmIcon(this.m_current_animal_data_mc["current_animal_icon_mc"]);
               this.m_current_animal_icon_mc.loadIcon(currentAnimalData.iconUrl);
               this.m_current_animal_icon_mc.setIconSize(45,45);
               this.m_current_animal_icon_mc.visible = true;
            }
            if(this.m_current_animal_data_mc.hasOwnProperty("current_name_tf"))
            {
               this.m_current_animal_name_tf = new ZwTextField(this.m_current_animal_data_mc["current_name_tf"],currentAnimalData.friendlyTitle);
               this.m_current_animal_name_tf.visible = true;
            }
         }
         if(m_window.hasOwnProperty("other_animals_mc"))
         {
            otherAnimalsData = this.manager.getOtherAnimalsData();
            this.m_other_animals_data_mc = m_window["other_animals_mc"] as MovieClip;
            this.m_other_animals_data_mc.visible = true;
            for(i = 0; i < NUM_OF_ANIMALS - 1; i++)
            {
               if(this.m_other_animals_data_mc.hasOwnProperty("other_animal_" + i))
               {
                  m_other_animal_mc = this.m_other_animals_data_mc["other_animal_" + i] as MovieClip;
                  if(m_other_animal_mc.hasOwnProperty("animal_icon_mc"))
                  {
                     m_other_animal_icon_mc = new FarmIcon(m_other_animal_mc["animal_icon_mc"]);
                  }
                  if(m_other_animal_mc.hasOwnProperty("animal_name_tf"))
                  {
                     m_other_animal_name_tf = new ZwTextField(m_other_animal_mc["animal_name_tf"],"other_animal_" + i + "_name_tf");
                  }
               }
               this.m_other_animals_mc.push(m_other_animal_mc);
               if(this.m_other_animals_mc[i])
               {
                  this.m_other_animals_mc[i].visible = true;
               }
               this.m_other_animal_icons_mc.push(m_other_animal_icon_mc);
               if(this.m_other_animal_icons_mc[i])
               {
                  this.m_other_animal_icons_mc[i].loadIcon(otherAnimalsData[i].iconUrl);
                  this.m_other_animal_icons_mc[i].setIconSize(45,45);
                  this.m_other_animal_icons_mc[i].visible = true;
               }
               this.m_other_animal_names_tf.push(m_other_animal_name_tf);
               if(this.m_other_animal_names_tf[i])
               {
                  this.m_other_animal_names_tf[i].text = otherAnimalsData[i].friendlyTitle;
                  this.m_other_animal_names_tf[i].visible = true;
               }
            }
         }
         if(m_window.hasOwnProperty("stage_counter_mc"))
         {
            this.m_stage_counter_mc = m_window["stage_counter_mc"] as MovieClip;
            this.m_stage_counter_mc.visible = true;
            if(this.m_stage_counter_mc.hasOwnProperty("milestone_icon_mc"))
            {
               this.m_milestone_icon_mc = new FarmIcon(this.m_stage_counter_mc["milestone_icon_mc"]);
               this.m_milestone_icon_mc.visible = true;
            }
            if(this.m_stage_counter_mc.hasOwnProperty("stage_meter_mc"))
            {
               this.m_stage_meter_mc = this.m_stage_counter_mc["stage_meter_mc"] as MovieClip;
               this.m_stage_meter_mc.visible = true;
               if(this.m_stage_meter_mc.hasOwnProperty("stage_bar_fill_mc"))
               {
                  this.m_stage_bar_fill_mc = this.m_stage_meter_mc["stage_bar_fill_mc"] as MovieClip;
                  this.m_stage_bar_fill_mc.visible = true;
               }
            }
            if(this.m_stage_counter_mc.hasOwnProperty("stage_count_tf"))
            {
               this.m_stage_count_tf = new ZwTextField(this.m_stage_counter_mc["stage_count_tf"]);
               this.m_stage_count_tf.visible = true;
            }
            this.m_stage_counter_mc.addEventListener(MouseEvent.MOUSE_OVER,this.onMilestoneMouseOver);
            this.m_stage_counter_mc.addEventListener(MouseEvent.MOUSE_OUT,this.onMilestoneMouseOut);
         }
         if(m_window.hasOwnProperty("milestone_hover_mc"))
         {
            this.m_milestoneHoverMc = m_window["milestone_hover_mc"] as MovieClip;
            this.m_milestoneHoverMc.visible = false;
            if(this.m_milestoneHoverMc.hasOwnProperty("milestone_big_mc"))
            {
               this.m_milestoneItem = new FarmIcon(this.m_milestoneHoverMc["milestone_big_mc"]);
               this.m_milestoneItem.visible = false;
            }
            if(this.m_milestoneHoverMc.hasOwnProperty("milestone_consumables_mc"))
            {
               this.m_consumable1 = new FarmIcon(this.m_milestoneHoverMc["milestone_consumables_mc"]);
               this.m_consumable1.visible = false;
            }
            if(this.m_milestoneHoverMc.hasOwnProperty("milestone_consumables_next_mc"))
            {
               this.m_consumable2 = new FarmIcon(this.m_milestoneHoverMc["milestone_consumables_next_mc"]);
               this.m_consumable2.visible = false;
            }
            if(this.m_milestoneHoverMc.hasOwnProperty("milestone_name_tf"))
            {
               this.m_milestoneRewardName_tf = new ZwTextField(this.m_milestoneHoverMc["milestone_name_tf"],"");
               this.m_milestoneRewardName_tf.visible = false;
            }
            if(this.m_milestoneHoverMc.hasOwnProperty("flavor_text_tf"))
            {
               this.m_milestoneFlavor_tf = new ZwTextField(this.m_milestoneHoverMc["flavor_text_tf"],"");
               this.m_milestoneFlavor_tf.visible = false;
            }
         }
         if(m_window.hasOwnProperty("animal_title_tf"))
         {
            this.m_animal_title_tf = new ZwTextField(m_window["animal_title_tf"],currentAnimalData.friendlyTitle);
            this.m_animal_title_tf.visible = true;
         }
         if(m_window.hasOwnProperty("farm_title_tf"))
         {
            this.m_farm_title_tf = new ZwTextField(m_window["farm_title_tf"],"in " + currentAnimalData.world);
            this.m_farm_title_tf.visible = true;
         }
         if(m_window.hasOwnProperty("feature_timer_tf"))
         {
            featureEndsInText = "Ends in " + this.manager.getFeatureEndDaysLeftText();
            this.m_feature_timer_tf = new ZwTextField(m_window["feature_timer_tf"],featureEndsInText);
            addWidget(this.m_feature_timer_tf);
            this.m_feature_timer_tf.visible = true;
         }
         if(m_window.hasOwnProperty("howDoesThisWork_mc"))
         {
            addWidget(this.m_whatIsThisBt = new FarmAnimatedTextButton(m_window["howDoesThisWork_mc"],"",this.onHowDoesThisWorkClick));
            this.m_whatIsThisBt.visible = true;
         }
         if(m_window.hasOwnProperty("unicorn_sanctuary_mc"))
         {
            this.m_unicorn_sanctuary_mc = m_window["unicorn_sanctuary_mc"] as MovieClip;
            this.m_unicorn_sanctuary_mc.visible = true;
            if(this.m_unicorn_sanctuary_mc.hasOwnProperty("view_rewards_bt"))
            {
               this.m_view_rewards_bt = new FarmAnimatedTextButton(this.m_unicorn_sanctuary_mc["view_rewards_bt"],"View!",this.onClickRewardBt);
               this.m_view_rewards_bt.visible = true;
            }
         }
         if(m_window.hasOwnProperty("animal_callout_mc"))
         {
            this.m_animalCalloutMc = m_window["animal_callout_mc"] as MovieClip;
            if(this.m_animalCalloutMc.hasOwnProperty("animal_callout_tf"))
            {
               this.m_animalCallout_tf = new ZwTextField(this.m_animalCalloutMc["animal_callout_tf"],featureEndsInText);
            }
            this.m_animalCalloutMc.visible = false;
         }
         if(m_window.hasOwnProperty("ftue_mc"))
         {
            this.m_tutorialMc = m_window["ftue_mc"] as MovieClip;
            if(this.m_tutorialMc)
            {
               m_tutorial = addWidget(new ZwFrame(m_window["ftue_mc"]),false) as ZwFrame;
               for(j = 0; j < 6; j++)
               {
                  buttonName1 = "okay_" + j.toString() + "_bt";
                  if(this.m_tutorialMc.hasOwnProperty(buttonName1))
                  {
                     this.m_tutorialButtons[j] = new FarmAnimatedTextButton(this.m_tutorialMc[buttonName1]);
                     m_tutorial.addWidget(this.m_tutorialButtons[j] as FarmAnimatedTextButton);
                     this.m_tutorialButtons[j].visible = false;
                  }
               }
            }
         }
         if(m_window.hasOwnProperty("ftue_mini_mc"))
         {
            this.m_tutorialMiniPerMc = m_window["ftue_mini_mc"] as MovieClip;
            this.m_minitutorial_frame = addWidget(new ZwFrame(this.m_tutorialMiniPerMc),false) as ZwFrame;
            if(this.m_tutorialMiniPerMc.hasOwnProperty("okay_ftue_mini_bt"))
            {
               this.m_minitutorial_frame.addWidget(new FarmAnimatedTextButton(this.m_tutorialMiniPerMc["okay_ftue_mini_bt"],"OK!",this.howDoesThisWorkFrameSwitch));
               this.m_tutorialMiniPerMc["okay_ftue_mini_bt"].visible = true;
            }
            this.m_tutorialMiniPerMc.visible = false;
         }
         this.refreshStats();
         this.startSinkTimers();
         if(!Global.player.getSeenFlag(this.ANIMAL_SANCTUARY_MAIN_FTUE_FLAG))
         {
            this.showTutorial1();
            Global.player.setSeenFlag(this.ANIMAL_SANCTUARY_MAIN_FTUE_FLAG);
            StatsManager.count("AnimalSanctuaryV2","FTUE","click");
         }
         this.startTimer();
      }
      
      private function onClickEarnButton(event:MouseEvent) : void
      {
         this.manager.openTasksWindow();
      }
      
      private function get manager() : AnimalSanctuaryV2Manager
      {
         return AnimalSanctuaryV2Manager.getInstance(this.m_featureName);
      }
      
      public function buyCouponsClick(event:Event) : void
      {
         this.manager.mainWindow.tintWindow();
         this.manager.mainWindow.enableInput = false;
         this.manager.buyConsumable(1,this.manager.mainWindow);
      }
      
      public function refreshStats() : void
      {
         for(var i:int = 0; i < NUM_OF_STATS; i++)
         {
            this.refreshStat(i);
         }
         this.refreshStageMeter();
         this.refreshAnimalBG();
      }
      
      private function refreshStageMeter(onOpenWindow:Boolean = false) : void
      {
         var milestoneName:String = null;
         var mileStoneItem:FarmItem = null;
         var milestoneAssetUrl:String = null;
         var couponsAverage:int = 0;
         var couponsRequiredToSink:int = 0;
         var filled:Number = NaN;
         if(this.manager.getSelectedAnimalSlot() != -1)
         {
            if(this.m_stage_counter_mc)
            {
               if(this.m_milestone_icon_mc)
               {
                  milestoneName = this.manager.MILESTONE_REWARDS[this.manager.getSelectedAnimalSlot()][this.manager.getStageOfAnimal()];
                  mileStoneItem = Global.farmGameSettingsManager.getFarmItemByName(milestoneName);
                  if(Boolean(mileStoneItem) && mileStoneItem.hasOwnProperty("iconUrl"))
                  {
                     milestoneAssetUrl = mileStoneItem.iconUrl;
                     this.m_milestone_icon_mc.loadIcon(milestoneAssetUrl);
                     this.m_milestone_icon_mc.setIconSize(50,50);
                  }
               }
               if(this.m_stage_count_tf)
               {
                  this.m_stage_count_tf.text = this.manager.getStageOfAnimal() + 1 + " / " + 5;
               }
            }
            if(this.m_stage_bar_fill_mc)
            {
               couponsAverage = this.manager.getTotalCouponsAverage();
               couponsRequiredToSink = int(this.manager.CONSUMABLE_COUNT_ARRAY[this.manager.getStageOfAnimal()]);
               filled = couponsAverage * 150 / couponsRequiredToSink;
               this.m_stage_bar_fill_mc.x = filled - 160;
            }
         }
      }
      
      private function refreshAnimalBG() : void
      {
         var assetPath:String = null;
         if(this.m_animal_sanctuary_mc)
         {
            assetPath = "assets/dialogs/animal_sanctuary_april_2020/" + this.manager.MILESTONE_FINAL_REWARDS[this.manager.getSelectedAnimalSlot() - 1] + "_" + (this.manager.getStageOfAnimal() + 1) + ".png";
            this.m_animal_sanctuary_mc.loadIcon(assetPath);
         }
      }
      
      public function refreshStat(resourceId:int) : void
      {
         var frameToPlay:int = 0;
         var filled:Number = NaN;
         var resourceState:int = this.manager.getResourceStateForCurrentAnimal(resourceId);
         var sinkTime:int = this.manager.getSinkTimeLeftForResource(resourceId);
         var couponsSinked:int = this.manager.getSinkedCouponCountByType(resourceId);
         var couponsRequiredToSink:int = int(this.manager.CONSUMABLE_COUNT_ARRAY[this.manager.getStageOfAnimal()]);
         if(this.m_stat_progresses_bt[resourceId])
         {
            this.m_stat_progresses_bt[resourceId].enabled = resourceState > this.manager.STATE_CRITICAL && resourceState < this.manager.STATE_COMPLETE && this.manager.requiredCosumablesAvailable(resourceId);
         }
         if(this.m_stat_conditions_bt[resourceId])
         {
            this.m_stat_conditions_bt[resourceId].visible = resourceState == this.manager.STATE_CRITICAL;
            this.m_stat_conditions_bt[resourceId].enabled = this.manager.requiredCosumablesAvailable(resourceId,1);
         }
         if(this.m_stat_progresses_tf[resourceId])
         {
            this.m_stat_progresses_tf[resourceId].text = couponsSinked + " / " + couponsRequiredToSink;
         }
         if(this.m_stat_conditions_mc[resourceId])
         {
            frameToPlay = resourceState == this.manager.STATE_COMPLETE ? 1 : int(3 - resourceState);
            this.m_stat_conditions_mc[resourceId].gotoAndStop(frameToPlay);
         }
         if(this.m_stat_condition_timers_tf[resourceId])
         {
            this.m_stat_condition_timers_tf[resourceId].visible = resourceState > this.manager.STATE_CRITICAL && resourceState < this.manager.STATE_COMPLETE;
            if(resourceState > this.manager.STATE_CRITICAL && resourceState < this.manager.STATE_COMPLETE)
            {
               this.m_stat_condition_timers_tf[resourceId].text = HUD.getformattedTimeLeft(sinkTime);
               this.m_stat_condition_timers_tf[resourceId].visible = true;
               this.m_stat_conditions_mc[resourceId]["condition_timer_tf"].text = this.m_stat_condition_timers_tf[resourceId].text = HUD.getformattedTimeLeft(sinkTime);
               this.m_stat_condition_timers_tf[resourceId].visible = true;
            }
            else
            {
               this.m_stat_condition_timers_tf[resourceId].text = "";
               this.m_stat_condition_timers_tf[resourceId].visible = false;
            }
         }
         if(resourceState == this.manager.STATE_COMPLETE)
         {
            this.stopSinkTimer(resourceId);
         }
         else if(sinkTime <= 0)
         {
            this.stopSinkTimer(resourceId,true);
            this.m_stat_condition_timers_tf[resourceId].text = "";
            this.m_stat_condition_timers_tf[resourceId].visible = false;
            StatsManager.count("AnimalSanctuaryV2","critical","enter",this.manager.getSelectedAnimal(),this.manager.VAL_COUPON_NAME_ARRAY[resourceId],"");
         }
         if(this.m_stat_bar_fills_mc[resourceId])
         {
            filled = couponsSinked / couponsRequiredToSink * LENGTH_STATS_PROGRESS_BAR;
            this.m_stat_bar_fills_mc[resourceId].x = -331 + filled - LENGTH_STATS_PROGRESS_BAR;
         }
      }
      
      private function getTootltipTextForResource(resourceId:int) : String
      {
         var resourceState:int = this.manager.getResourceStateForCurrentAnimal(resourceId);
         return this.manager.RESOURCE_STATE_HOVER_TEXTS[resourceId];
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
      
      public function onSinkClick(slotIndex:int) : Function
      {
         return function(evt:MouseEvent):void
         {
            manager.sinkConsumable(slotIndex);
         };
      }
      
      public function onStarvSinkClick(slotIndex:int) : Function
      {
         return function(evt:MouseEvent):void
         {
            tintWindow();
            enableInput = false;
            manager.sinkConsumableOnStarve(slotIndex);
         };
      }
      
      override public function refreshWindow() : void
      {
         this.refreshCouponsCount();
         this.refreshStats();
      }
      
      public function startSinkWaitTime(resourceId:int) : void
      {
         this.m_skip_timers[resourceId] = new Timer(1000);
         this.m_skip_timers[resourceId].addEventListener(TimerEvent.TIMER,this.onskipWaitTimer(resourceId));
         this.m_skip_timers[resourceId].start();
      }
      
      public function onskipWaitTimer(resourceId:int) : Function
      {
         return function(event:TimerEvent):void
         {
            refreshStat(resourceId);
         };
      }
      
      private function stopSinkTimer(resourceId:int, showNPC:Boolean = false) : void
      {
         if(this.m_skip_timers[resourceId])
         {
            this.m_skip_timers[resourceId].stop();
            this.m_skip_timers[resourceId].removeEventListener(TimerEvent.TIMER,this.onskipWaitTimer(resourceId));
            this.m_skip_timers[resourceId] = null;
            if(showNPC)
            {
               this.showNPCCalloutUtil(resourceId);
            }
         }
      }
      
      public function startSinkTimers() : void
      {
         for(var i:int = 0; i < NUM_OF_STATS; i++)
         {
            this.startSinkWaitTime(i);
         }
      }
      
      private function stopSinkTimers() : void
      {
         for(var i:int = 0; i < NUM_OF_STATS; i++)
         {
            this.stopSinkTimer(i);
         }
      }
      
      override public function close() : void
      {
         this.stopSinkTimers();
         this.stopTimer();
         super.close();
      }
      
      public function onClickRewardBt(event:Event) : void
      {
         this.manager.openRewardWindow();
      }
      
      public function showTutorial1() : void
      {
         if(this.m_tutorialMc)
         {
            this.m_tutorialMc.visible = true;
            m_tutorial.visible = true;
            this.preSwitchChanges1(0);
         }
      }
      
      protected function preSwitchChanges1(sceneNumber:int) : void
      {
         var button0:FarmAnimatedTextButton = null;
         var button1:FarmAnimatedTextButton = null;
         var button2:FarmAnimatedTextButton = null;
         var button3:FarmAnimatedTextButton = null;
         var button4:FarmAnimatedTextButton = null;
         var button5:FarmAnimatedTextButton = null;
         switch(sceneNumber)
         {
            case 0:
               button0 = this.m_tutorialButtons[0] as FarmAnimatedTextButton;
               button0.text = "OK!";
               button0.visible = true;
               button0.enabled = true;
               button0.callback = this.onTutorialOkayButtonClick1;
               this.hideOtherTutorialButtonsExpect1(0);
               (m_tutorial.element as MovieClip).gotoAndStop(1);
               break;
            case 1:
               button1 = this.m_tutorialButtons[1] as FarmAnimatedTextButton;
               button1.text = "OK!";
               button1.visible = true;
               button1.callback = this.onTutorialOkayButtonClick1;
               this.hideOtherTutorialButtonsExpect1(1);
               (m_tutorial.element as MovieClip).gotoAndStop(2);
               break;
            case 2:
               button2 = this.m_tutorialButtons[2] as FarmAnimatedTextButton;
               button2.text = "OK!";
               button2.visible = true;
               button2.callback = this.onTutorialOkayButtonClick1;
               this.hideOtherTutorialButtonsExpect1(2);
               (m_tutorial.element as MovieClip).gotoAndStop(3);
               break;
            case 3:
               button3 = this.m_tutorialButtons[3] as FarmAnimatedTextButton;
               button3.text = "OK!";
               button3.visible = true;
               button3.callback = this.onTutorialOkayButtonClick1;
               this.hideOtherTutorialButtonsExpect1(3);
               (m_tutorial.element as MovieClip).gotoAndStop(4);
               break;
            case 4:
               button4 = this.m_tutorialButtons[4] as FarmAnimatedTextButton;
               button4.text = "OK!";
               button4.visible = true;
               button4.callback = this.onTutorialOkayButtonClick1;
               this.hideOtherTutorialButtonsExpect1(4);
               (m_tutorial.element as MovieClip).gotoAndStop(5);
               break;
            case 5:
               button5 = this.m_tutorialButtons[5] as FarmAnimatedTextButton;
               button5.text = "OK!";
               button5.visible = true;
               button5.callback = this.onTutorialOkayButtonClick1;
               this.hideOtherTutorialButtonsExpect1(5);
               (m_tutorial.element as MovieClip).gotoAndStop(6);
         }
      }
      
      protected function onTutorialOkayButtonClick1(event:MouseEvent) : void
      {
         if(tutorialSceneNumber < 5)
         {
            ++tutorialSceneNumber;
            this.preSwitchChanges1(tutorialSceneNumber);
         }
         else
         {
            hideTutorial();
         }
      }
      
      private function hideOtherTutorialButtonsExpect1(buttonNo:int) : void
      {
         for(var i:int = 0; i < this.m_tutorialButtons.length; i++)
         {
            if(i != buttonNo)
            {
               this.m_tutorialButtons[i].visible = false;
            }
         }
      }
      
      private function onMilestoneMouseOver(e:Event = null) : void
      {
         var milestoneName:String = null;
         var mileStoneItem:FarmItem = null;
         var level:int = 0;
         var c1Item:FarmItem = null;
         var levelTemp:int = 0;
         var c2Item:FarmItem = null;
         if(this.m_milestoneHoverMc)
         {
            this.m_milestoneHoverMc.visible = true;
            if(this.m_milestoneItem)
            {
               milestoneName = this.manager.MILESTONE_REWARDS[this.manager.getSelectedAnimalSlot()][this.manager.getStageOfAnimal()];
               mileStoneItem = Global.farmGameSettingsManager.getFarmItemByName(milestoneName);
               this.m_milestoneItem.loadIcon(mileStoneItem.iconUrl);
               this.m_milestoneItem.setIconSize(100,100);
               this.m_milestoneItem.visible = true;
               if(this.m_milestoneRewardName_tf)
               {
                  this.m_milestoneRewardName_tf.text = mileStoneItem.friendlyTitle;
                  this.m_milestoneRewardName_tf.visible = true;
               }
            }
            if(this.m_consumable1)
            {
               this.m_consumable1.visible = false;
               level = this.manager.getStageOfAnimal();
               if(level < 3)
               {
                  c1Item = Global.farmGameSettingsManager.getFarmItemByName(this.manager.MILESTONE_CONSUMABLES_REWARDS[level][0]);
                  this.m_consumable1.loadIcon(c1Item.iconUrl);
                  this.m_consumable1.setIconSize(50,50);
                  this.m_consumable1.visible = true;
               }
            }
            if(this.m_consumable2)
            {
               this.m_consumable2.visible = false;
               levelTemp = this.manager.getStageOfAnimal();
               if(levelTemp < 3)
               {
                  c2Item = Global.farmGameSettingsManager.getFarmItemByName(this.manager.MILESTONE_CONSUMABLES_REWARDS[levelTemp][1]);
                  this.m_consumable2.loadIcon(c2Item.iconUrl);
                  this.m_consumable2.setIconSize(50,50);
                  this.m_consumable2.visible = true;
               }
            }
         }
      }
      
      private function onMilestoneMouseOut(e:Event = null) : void
      {
         if(this.m_milestoneHoverMc)
         {
            this.m_milestoneHoverMc.visible = false;
         }
         if(this.m_milestoneItem)
         {
            this.m_milestoneItem.visible = false;
         }
         if(this.m_consumable1)
         {
            this.m_consumable1.visible = false;
         }
         if(this.m_consumable2)
         {
            this.m_consumable2.visible = false;
         }
         if(this.m_milestoneRewardName_tf)
         {
            this.m_milestoneRewardName_tf.visible = false;
         }
      }
      
      public function showNPCCallouts(title:String, text:String) : void
      {
         if(Boolean(this.m_animalCalloutMc) && Boolean(this.m_animalCallout_tf))
         {
            this.m_animalCallout_tf.text = text;
            this.m_animalCalloutMc.visible = true;
            this.m_animalCalloutMc.gotoAndPlay(1);
            this.startTimerNPC();
         }
      }
      
      public function startTimerNPC() : void
      {
         if(this.m_timerNPC5 == null)
         {
            this.m_timerNPC5 = new Timer(15000);
            this.m_timerNPC5.addEventListener(TimerEvent.TIMER,this.onTimerNPC5);
            this.m_timerNPC5.start();
         }
      }
      
      private function onTimerNPC5(event:TimerEvent) : void
      {
         this.stopTimerNPC5();
         if(this.m_animalCalloutMc)
         {
            this.m_animalCalloutMc.visible = false;
         }
      }
      
      public function showNPCCalloutUtil(indexNPC:int) : void
      {
         var text:String = this.manager.getCallOutTextByAnimal(this.manager.getSelectedAnimal(),indexNPC);
         this.showNPCCallouts(this.manager.VAL_ANIMAL_NAME_ARRAY[this.manager.getSelectedAnimalSlot() - 1],text);
      }
      
      private function stopTimerNPC5() : void
      {
         if(this.m_timerNPC5)
         {
            this.m_timerNPC5.stop();
            this.m_timerNPC5.removeEventListener(TimerEvent.TIMER,this.onTimerNPC5);
            this.m_timerNPC5 = null;
         }
      }
      
      private function onHowDoesThisWorkClick(event:Event) : void
      {
         if(this.m_minitutorial_frame)
         {
            (this.m_minitutorial_frame.element as MovieClip).gotoAndStop(1);
            this.m_minitutorial_frame.visible = true;
         }
      }
      
      private function howDoesThisWorkFrameSwitch(event:Event = null) : void
      {
         var totalFrames:int = int(this.m_minitutorial_frame.element.totalFrames);
         var currentFrame:int = int(this.m_minitutorial_frame.element.currentFrame);
         if(currentFrame + 1 <= totalFrames)
         {
            (this.m_minitutorial_frame.element as MovieClip).gotoAndStop(currentFrame + 1);
         }
         else
         {
            this.m_minitutorial_frame.visible = false;
         }
      }
      
      public function startTimer() : void
      {
         this.m_timer = new Timer(1000);
         this.m_timer.addEventListener(TimerEvent.TIMER,this.onTimer);
         this.m_timer.start();
      }
      
      private function onTimer(event:TimerEvent) : void
      {
         if(this.manager.isFeatureActive)
         {
            this.m_feature_timer_tf.text = "Ends in " + this.manager.getFeatureEndDaysLeftText();
         }
         else
         {
            this.manager.removeHud();
            this.close();
         }
      }
      
      private function stopTimer() : void
      {
         if(this.m_timer)
         {
            this.m_timer.stop();
            this.m_timer.removeEventListener(TimerEvent.TIMER,this.onTimer);
            this.m_timer = null;
         }
      }
   }
}

