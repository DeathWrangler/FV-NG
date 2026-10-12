package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import Managers.PetAcademyManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.PetAcademyAnimalFrame;
   import Widgets.Frames.PetAcademyProfessionsSlotContainerFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class PetAcademyMainWindow extends FarmWindowWithTutorial
   {
      
      private static const NUM_TUTORIAL_SCENES:int = 5;
      
      private static const BODY_TF:String = "body_tf";
      
      private var m_featureName:String;
      
      private var m_showTutorialWithEAPage:Boolean;
      
      private var m_activeExam_mc:MovieClip;
      
      private var m_activeExam_bt:FarmAnimatedTextButton;
      
      private var m_activeExam_tf:ZwTextField;
      
      private var m_activeExam_title:ZwTextField;
      
      private var m_consumableArray:Array = [];
      
      private var m_consumableBuyBtArray:Array = [];
      
      private var m_consumableCraftBtArray:Array = [];
      
      private var m_consumableAskBtArray:Array = [];
      
      private var m_consumableCountTextArray:Array = [];
      
      private var m_consumanleIconArray:Array = [];
      
      private var m_professionsFrame:PetAcademyProfessionsSlotContainerFrame;
      
      private var m_animalSlotFrame:PetAcademyAnimalFrame;
      
      private const TITLE_TF:String = "title_tf";
      
      private var m_activeExamIcon:FarmIcon;
      
      private var animalForBuyAll:*;
      
      private var m_timerFrame:ZwFrame;
      
      private var m_timerTextField:ZwTextField;
      
      public function PetAcademyMainWindow(featureName:String, assetPath:String, showTutorialWithEAPage:Boolean = false)
      {
         this.m_featureName = featureName;
         this.m_showTutorialWithEAPage = showTutorialWithEAPage;
         var numOfTutorialPages:int = NUM_TUTORIAL_SCENES;
         super(this.m_featureName,assetPath,numOfTutorialPages,true,true);
      }
      
      override protected function postLoadComplete() : void
      {
         var activeAnimalItem:FarmItem = null;
         var imageurl:String = null;
         var finalSlotIcon:String = null;
         super.postLoadComplete();
         if(m_window.hasOwnProperty("whatisthis_bt"))
         {
            addWidget(new ZwButton(m_window.whatisthis_bt,this.howDoesThisWorkClick));
         }
         if(m_window.hasOwnProperty("timeleft_mc") && Boolean(m_window["timeleft_mc"].hasOwnProperty("time_tf")))
         {
            addWidget(this.m_timerFrame = new ZwFrame(m_window.timeleft_mc));
            if(this.m_timerFrame)
            {
               this.m_timerTextField = new ZwTextField(m_window.timeleft_mc.time_tf,this.timeRemaining());
               this.m_timerTextField.visible = true;
               m_window.timeleft_mc.left_tf.visible = true;
            }
         }
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            addWidget(new ZwTextField(m_window[this.TITLE_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_mainWindowTitle")));
         }
         if(m_window.hasOwnProperty(BODY_TF))
         {
            if(this.manager.isFeatureEnd() && this.manager.isAllProfessionCompletedForAnimals())
            {
               addWidget(new ZwTextField(m_window[BODY_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_featureend_mainWindowBodyText")));
            }
            else if(this.manager.isFeatureEnd())
            {
               addWidget(new ZwTextField(m_window[BODY_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_featureendincompleteprofeesion_mainWindowBodyText")));
            }
            else
            {
               addWidget(new ZwTextField(m_window[BODY_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_mainWindowBodyText")));
            }
         }
         if(m_window.hasOwnProperty("activeexam_mc") && this.manager.isAnyExamActive() == true)
         {
            this.m_activeExam_mc = m_window["activeexam_mc"] as MovieClip;
            addWidget(this.m_activeExam_bt = new FarmAnimatedTextButton(this.m_activeExam_mc["exam_bt"],"Continue",this.manager.showExamUI));
            addWidget(this.m_activeExam_tf = new ZwTextField(this.m_activeExam_mc["exam_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_activeExamText")));
            this.m_activeExamIcon = new FarmIcon(this.m_activeExam_mc["icon_mc"]);
            this.m_activeExam_tf.visible = false;
         }
         if(this.manager.isAnyExamActive() == true)
         {
            this.m_activeExam_mc.visible = true;
            activeAnimalItem = Global.farmGameSettingsManager.getFarmItemByName(this.manager.activeProfession);
            this.m_activeExam_title = new ZwTextField(this.m_activeExam_mc["title_tf"],"Exam in Progress!");
            imageurl = activeAnimalItem.getImageByName("icon",false);
            finalSlotIcon = imageurl.substr(0,imageurl.length - 8) + "base5_icon.png";
            this.m_activeExamIcon.loadIcon(finalSlotIcon);
            this.m_activeExamIcon.attachTooltip(new FarmTextTooltip("Continue training your pet into a professional!"));
         }
         else
         {
            this.m_activeExam_mc = m_window["activeexam_mc"] as MovieClip;
            addWidget(this.m_activeExam_tf = new ZwTextField(this.m_activeExam_mc["exam_tf"],"Choose a course below to view trainees."));
            this.m_activeExam_mc.visible = true;
            this.m_activeExam_title = new ZwTextField(this.m_activeExam_mc["title_tf"],"");
            this.m_activeExam_title.visible = false;
            addWidget(this.m_activeExam_bt = new FarmAnimatedTextButton(this.m_activeExam_mc["exam_bt"],"Continue",this.manager.showExamUI));
            this.m_activeExam_bt.visible = false;
         }
         if(m_window.hasOwnProperty("animals_mc"))
         {
            this.m_animalSlotFrame = new PetAcademyAnimalFrame(m_window.animals_mc,this);
            if(this.m_animalSlotFrame)
            {
               addWidget(this.m_animalSlotFrame);
               this.populateAnimalsSlots();
            }
         }
         for(var i:int = 0; i < 3; i++)
         {
            this.m_consumableArray[i] = m_window["consumable" + i.toString() + "_mc"] as MovieClip;
            this.m_consumableArray[i].visible = true;
            this.m_consumableBuyBtArray[i] = new FarmAnimatedTextButton(this.m_consumableArray[i]["buy_bt"],"Buy",this.buyClickListener(i));
            this.m_consumableCraftBtArray[i] = new FarmAnimatedTextButton(this.m_consumableArray[i]["craftpotion_bt"],"Craft",this.craftClickListener(i));
            this.m_consumableAskBtArray[i] = new FarmAnimatedTextButton(this.m_consumableArray[i]["post_mc"],"Ask",this.askClickListener(i));
            this.m_consumableCountTextArray[i] = new ZwTextField(this.m_consumableArray[i].rewardcount_tf,"x0");
            this.m_consumableCountTextArray[i].text = "x" + this.manager.consumableCount(i).toString();
            this.m_consumanleIconArray[i] = new FarmIcon(this.m_consumableArray[i].icon_mc,this.manager.consumableFarmItem(i).getImageByName("icon")) as FarmIcon;
            this.m_consumanleIconArray[i].visible = true;
            this.m_consumanleIconArray[i].attachTooltip(new FarmTextTooltip(this.manager.consumableFarmItem(i).friendlyTitle));
         }
         if(m_window.hasOwnProperty("professions_mc"))
         {
            this.m_professionsFrame = new PetAcademyProfessionsSlotContainerFrame(m_window.professions_mc,this);
            if(this.m_professionsFrame)
            {
               addWidget(this.m_professionsFrame,false);
            }
         }
         this.refreshAskButtons();
      }
      
      public function populateProfessionsSlots(slotIndex:int) : void
      {
         var professions:Array = new Array();
         var i:int = 0;
         var animalsNameArray:Array = this.manager.getAminalNames();
         var animalName:String = animalsNameArray[slotIndex];
         var professionsArray:Array = this.manager.getProfessionsForAnimal(animalName);
         var professionsCost:Array = this.manager.getProfessionsForAnimalCost(animalName);
         while(i < professionsArray.length)
         {
            professions.push({
               "slotIndex":i,
               "animalName":animalName,
               "professionName":professionsArray[i],
               "cost":professionsCost[i]
            });
            i++;
         }
         this.m_professionsFrame.items = professions;
         this.m_professionsFrame.animal = animalName;
         this.m_professionsFrame.visible = true;
         FarmStatsManager.count("animal_academy","click_animal_selection",animalName);
      }
      
      private function onBuyAllanimalsCallback(event:MouseEvent) : void
      {
         UI.displayMessage("Do you want to spend " + this.manager.getBuyAllAverage(this.animalForBuyAll) + " Farm Cash to unlock all the animals here??",GenericPopup.TYPE_ACCEPTCANCEL,this.onBuyAllanimalsAccept,"",true);
      }
      
      public function getSlotIndexFromFrame(animalName:String, event:MouseEvent) : void
      {
         this.animalForBuyAll = animalName;
         this.onBuyAllanimalsCallback(event);
      }
      
      public function onBuyAllanimalsAccept(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.YES)
         {
            this.onBuyAllProfessions();
         }
      }
      
      public function onBuyAllProfessions() : void
      {
         var professions:Array = new Array();
         var i:int = 0;
         var animalName:String = this.animalForBuyAll;
         var professionsArray:Array = this.manager.getProfessionsForAnimal(animalName);
         while(i < professionsArray.length)
         {
            professions.push({
               "slotIndex":i,
               "animalName":animalName,
               "professionName":professionsArray[i],
               "cost":0
            });
            i++;
         }
         PetAcademyManager.getInstance().buyAllAnimalsByCost(animalName);
         this.m_professionsFrame.items = professions;
         this.m_professionsFrame.animal = animalName;
         this.m_professionsFrame.visible = true;
         FarmStatsManager.count("animal_academy","click_animal_selection",animalName);
      }
      
      public function checkBuyAll() : void
      {
         this.m_professionsFrame.checkBuyAllButton = "";
      }
      
      public function getFrameTitle(slotIndex:int) : String
      {
         var slotnameArray:* = ["School Of Hospitality","School Of Computing","School Of Transport","Wildlife School","School Of Grooming","Ancient Studies"];
         return slotnameArray[slotIndex];
      }
      
      private function populateAnimalsSlots() : void
      {
         var animals:Array = [];
         var i:int = 0;
         var animalsNameArray:Array = this.manager.getAminalNames();
         var animalPrices:Array = this.manager.AminalPrices;
         var slotnameArray:* = ["School Of\nHospitality","School Of\nComputing","School Of\nTransport","Wildlife\nSchool","School Of\nGrooming","Ancient\nStudies"];
         while(i < animalsNameArray.length)
         {
            animals.push({
               "slotIndex":i,
               "price":animalPrices[i],
               "animalName":animalsNameArray[i],
               "slotName":slotnameArray[i]
            });
            i++;
         }
         this.m_animalSlotFrame.items = animals;
      }
      
      private function howDoesThisWorkClick(event:Event) : void
      {
         showTutorial();
      }
      
      private function get manager() : PetAcademyManager
      {
         return PetAcademyManager.getInstance();
      }
      
      public function buyClickListener(slotIndex:int) : Function
      {
         return function(evt:MouseEvent):void
         {
            manager.mainWindow.tintWindow();
            manager.mainWindow.enableInput = false;
            manager.buyConsumable(slotIndex,manager.mainWindow);
         };
      }
      
      public function craftClickListener(slotIndex:int) : Function
      {
         return function(evt:MouseEvent):void
         {
            manager.craftConsumableFromMainWindow(slotIndex);
         };
      }
      
      public function askClickListener(slotIndex:int) : Function
      {
         return function(evt:MouseEvent):void
         {
            manager.askConsumable(slotIndex);
         };
      }
      
      public function refreshAskButtons(e:Event = null) : void
      {
         var xPostTimeRemaining1:int = 0;
         var timeRemainingone:Array = null;
         var xPostTimeRemaining2:int = 0;
         var timeRemaining2:Array = null;
         var xPostTimeRemaining3:int = 0;
         var timeRemaining:Array = null;
         if(this.m_consumableAskBtArray[0])
         {
            xPostTimeRemaining1 = this.manager.getThrottleTimeRemaining(PetAcademyManager.FEED1_NAME);
            if(xPostTimeRemaining1 > 0)
            {
               timeRemainingone = FarmGameUtil.parseTimeLeft(xPostTimeRemaining1);
               if(timeRemainingone[1] !== 0 || timeRemainingone[2] !== 0)
               {
                  FarmGameUtil.disableButtonAndShowTooltip(this.m_consumableAskBtArray[0],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"asksnowflake_timeleft",{
                     "hrs":timeRemainingone[1],
                     "min":timeRemainingone[2]
                  }));
               }
               else
               {
                  FarmGameUtil.disableButtonAndShowTooltip(this.m_consumableAskBtArray[0],"Ask again in " + timeRemainingone[3] + " seconds");
               }
               this.m_consumableAskBtArray[0].callback = null;
            }
            else
            {
               this.m_consumableAskBtArray[0].enabled = true;
               this.m_consumableAskBtArray[0].detachTooltip();
            }
         }
         if(this.m_consumableAskBtArray[1])
         {
            xPostTimeRemaining2 = this.manager.getThrottleTimeRemaining(PetAcademyManager.FEED2_NAME);
            if(xPostTimeRemaining2 > 0)
            {
               timeRemaining2 = FarmGameUtil.parseTimeLeft(xPostTimeRemaining2);
               if(timeRemaining2[1] !== 0 || timeRemaining2[2] !== 0)
               {
                  FarmGameUtil.disableButtonAndShowTooltip(this.m_consumableAskBtArray[1],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"asksnowflake_timeleft",{
                     "hrs":timeRemaining2[1],
                     "min":timeRemaining2[2]
                  }));
               }
               else
               {
                  FarmGameUtil.disableButtonAndShowTooltip(this.m_consumableAskBtArray[1],"Ask again in " + timeRemaining2[3] + " seconds");
               }
               this.m_consumableAskBtArray[1].callback = null;
            }
            else
            {
               this.m_consumableAskBtArray[1].enabled = true;
               this.m_consumableAskBtArray[1].detachTooltip();
            }
         }
         if(this.m_consumableAskBtArray[2])
         {
            xPostTimeRemaining3 = this.manager.getThrottleTimeRemaining(PetAcademyManager.FEED3_NAME);
            if(xPostTimeRemaining3 > 0)
            {
               timeRemaining = FarmGameUtil.parseTimeLeft(xPostTimeRemaining3);
               if(timeRemaining[1] !== 0 || timeRemaining[2] !== 0)
               {
                  FarmGameUtil.disableButtonAndShowTooltip(this.m_consumableAskBtArray[2],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"asksnowflake_timeleft",{
                     "hrs":timeRemaining[1],
                     "min":timeRemaining[2]
                  }));
               }
               else
               {
                  FarmGameUtil.disableButtonAndShowTooltip(this.m_consumableAskBtArray[2],"Ask again in " + timeRemaining[3] + " seconds");
               }
               this.m_consumableAskBtArray[2].callback = null;
            }
            else
            {
               this.m_consumableAskBtArray[2].enabled = true;
               this.m_consumableAskBtArray[2].detachTooltip();
            }
         }
      }
      
      override public function refreshWindow() : void
      {
         this.refreshAskButtons();
         for(var i:int = 0; i < 3; i++)
         {
            this.m_consumableCountTextArray[i].text = "x" + this.manager.consumableCount(i).toString();
         }
      }
      
      private function timeRemaining() : String
      {
         return this.manager.getTimeRemainingInFreindlyTime();
      }
   }
}

