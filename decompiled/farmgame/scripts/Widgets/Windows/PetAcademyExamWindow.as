package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.PetAcademyManager;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Frames.HalloweenUSARedeemFrame;
   import Widgets.Frames.PetAcademyConsumableFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.TextFields.FarmTextField;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class PetAcademyExamWindow extends FarmWindowWithTutorial
   {
      
      private static const NUM_TUTORIAL_SCENES:int = 3;
      
      private const TITLE_TF:String = "title_tf";
      
      private const BODY_TF:String = "body_tf";
      
      private const SLOTS_MC:String = "slots_mc";
      
      private var m_slots:HalloweenUSARedeemFrame;
      
      private var m_featureName:String = null;
      
      private var m_current_mc:MovieClip;
      
      private var m_effect_mc:MovieClip;
      
      private var m_final_mc:MovieClip;
      
      private var m_score_mc:MovieClip;
      
      private var m_currentHeaderText:FarmTextField;
      
      private var m_finalHeaderText:FarmTextField;
      
      private var m_counterArray:Array = new Array();
      
      private var m_Consumable1Frame:PetAcademyConsumableFrame;
      
      private var m_Consumable2Frame:PetAcademyConsumableFrame;
      
      private var m_Consumable3Frame:PetAcademyConsumableFrame;
      
      private var m_currentIcon_mc:FarmIcon;
      
      private var m_finalIcon_mc:FarmIcon;
      
      private var m_round_tf:FarmTextField;
      
      public function PetAcademyExamWindow(featureName:String, assetPath:String = "")
      {
         this.m_featureName = featureName;
         var numOfTutorialPages:int = NUM_TUTORIAL_SCENES;
         super(this.m_featureName + "_exam",assetPath,numOfTutorialPages,true,true);
      }
      
      override protected function postLoadComplete() : void
      {
         var currentSlotIcon:String = null;
         var imageurl:String = null;
         var finalSlotIcon:String = null;
         var i:int = 0;
         super.postLoadComplete();
         var activeAnimalItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.manager.activeProfession);
         if(m_window.hasOwnProperty("whatisthis_bt"))
         {
            addWidget(new ZwButton(m_window.whatisthis_bt,this.howDoesThisWorkClick));
         }
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            m_window[this.TITLE_TF].visible = true;
            m_window[this.TITLE_TF].text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_ExamWindow_Title");
         }
         if(m_window.hasOwnProperty(this.BODY_TF))
         {
            m_window[this.BODY_TF].visible = true;
            m_window[this.BODY_TF].text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_ExamWindow_BodyText");
         }
         if(m_window.hasOwnProperty("current_mc"))
         {
            this.m_current_mc = m_window["current_mc"] as MovieClip;
            imageurl = activeAnimalItem.getImageByName("icon",false);
            currentSlotIcon = imageurl.substr(0,imageurl.length - 8) + "base" + this.manager.activeExamLevel + "_icon.png";
            this.m_currentIcon_mc = new FarmIcon(this.m_current_mc.icon_mc,currentSlotIcon);
            this.m_current_mc.visible = true;
            this.m_currentHeaderText = new FarmTextField(this.m_current_mc["header_tf"],"Level " + this.manager.activeExamLevel + "/5");
         }
         if(m_window.hasOwnProperty("final_mc"))
         {
            this.m_final_mc = m_window["final_mc"] as MovieClip;
            finalSlotIcon = imageurl.substr(0,imageurl.length - 8) + "base5_icon.png";
            this.m_finalIcon_mc = new FarmIcon(this.m_final_mc.icon_mc,finalSlotIcon);
            this.m_final_mc.visible = true;
            this.m_finalHeaderText = new FarmTextField(this.m_final_mc["header_tf"],activeAnimalItem.friendlyTitle);
         }
         if(m_window.hasOwnProperty("score_mc"))
         {
            this.m_score_mc = m_window["score_mc"] as MovieClip;
            this.m_score_mc.visible = true;
            for(i = 0; i < 5; i++)
            {
               this.m_counterArray[i] = this.m_score_mc["count_mc_" + i.toString()] as MovieClip;
               if(i > this.manager.activeExamLevel)
               {
                  this.m_counterArray[i].gotoAndStop(1);
               }
               else if(i < this.manager.activeExamLevel)
               {
                  this.m_counterArray[i].gotoAndStop(3);
               }
               else
               {
                  this.m_counterArray[i].gotoAndStop(2);
               }
            }
            if(this.m_score_mc.hasOwnProperty("round_tf"))
            {
               this.m_round_tf = new FarmTextField(this.m_score_mc["round_tf"]);
               this.m_round_tf.text = this.manager.activeExamLevel.toString() + "/5";
               this.m_round_tf.visible = false;
            }
         }
         if(m_window.hasOwnProperty("set3_mc"))
         {
            this.m_Consumable3Frame = new PetAcademyConsumableFrame(m_window.set3_mc,this);
            this.m_Consumable3Frame.visible = false;
         }
         if(m_window.hasOwnProperty("set2_mc"))
         {
            this.m_Consumable2Frame = new PetAcademyConsumableFrame(m_window.set2_mc,this);
            this.m_Consumable2Frame.visible = false;
         }
         if(m_window.hasOwnProperty("set1_mc"))
         {
            this.m_Consumable1Frame = new PetAcademyConsumableFrame(m_window.set1_mc,this);
            this.m_Consumable1Frame.visible = false;
         }
         this.populateConsumableSlots();
      }
      
      private function get manager() : PetAcademyManager
      {
         return PetAcademyManager.getInstance();
      }
      
      private function howDoesThisWorkClick(event:Event) : void
      {
         showTutorial();
      }
      
      private function populateConsumableSlots() : void
      {
         this.hideAllConsumableFrames();
         var consumableCountArray:Array = this.manager.getConsumableRequiredForAnimalExamLevel(this.manager.activeAnimal,this.manager.activeProfession,this.manager.activeExamLevel);
         var requiredConsumableTypeCount:int = 0;
         var i:int = 0;
         var slotData:Array = [];
         while(i < 3)
         {
            if(consumableCountArray[i] > 0)
            {
               slotData.push({
                  "consumableCode":this.manager.consumableCodeArray[i],
                  "slotIndex":i,
                  "required":consumableCountArray[i]
               });
               requiredConsumableTypeCount++;
            }
            i++;
         }
         switch(requiredConsumableTypeCount)
         {
            case 1:
               this.m_Consumable1Frame.visible = true;
               this.m_Consumable1Frame.items = slotData;
               break;
            case 2:
               this.m_Consumable2Frame.visible = true;
               this.m_Consumable2Frame.items = slotData;
               break;
            case 3:
               this.m_Consumable3Frame.visible = true;
               this.m_Consumable3Frame.items = slotData;
         }
      }
      
      public function hideAllConsumableFrames() : void
      {
         this.m_Consumable3Frame.visible = false;
         this.m_Consumable2Frame.visible = false;
         this.m_Consumable1Frame.visible = false;
      }
      
      override public function close() : void
      {
         super.close();
         this.manager.handleHUDClick();
      }
      
      override public function refreshWindow() : void
      {
         var currentSlotIcon:String = null;
         var activeAnimalItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.manager.activeProfession);
         var imageurl:String = activeAnimalItem.getImageByName("icon",false);
         currentSlotIcon = imageurl.substr(0,imageurl.length - 8) + "base" + this.manager.activeExamLevel + "_icon.png";
         this.m_currentIcon_mc.loadIcon(currentSlotIcon);
         this.m_currentHeaderText.text = "Level " + this.manager.activeExamLevel + "/5";
         this.m_round_tf.text = this.manager.activeExamLevel.toString() + "/5";
         this.populateConsumableSlots();
         this.refreshExamLevelProgressMeter();
      }
      
      public function refreshExamLevelProgressMeter() : void
      {
         var isQuestComplete:Boolean = this.manager.checkStageCompletionForAnimationToPlay();
         if(m_window.hasOwnProperty("current_mc"))
         {
            this.m_current_mc = m_window.current_mc;
            if(isQuestComplete && this.m_current_mc.hasOwnProperty("effect_mc"))
            {
               this.m_effect_mc = this.m_current_mc["effect_mc"] as MovieClip;
               this.m_effect_mc.visible = true;
            }
            else
            {
               this.m_effect_mc = this.m_current_mc["effect_mc"] as MovieClip;
               this.m_effect_mc.visible = false;
            }
         }
         this.m_score_mc = m_window["score_mc"] as MovieClip;
         this.m_score_mc.visible = true;
         for(var i:int = 0; i < 5; i++)
         {
            this.m_counterArray[i] = this.m_score_mc["count_mc_" + i.toString()] as MovieClip;
            if(i > this.manager.activeExamLevel)
            {
               this.m_counterArray[i].gotoAndStop(1);
            }
            else if(i < this.manager.activeExamLevel)
            {
               this.m_counterArray[i].gotoAndStop(3);
            }
            else
            {
               this.m_counterArray[i].gotoAndStop(2);
            }
         }
      }
   }
}

