package Widgets.Frames
{
   import Cache.Classes.ZCacheUtil;
   import Classes.util.ZLocUtils;
   import Managers.FaceOffManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Slots.FaceOffConsolationSlot;
   import Widgets.Slots.FaceOffNotPickedSlot;
   import Widgets.Slots.FaceOffPickedSlot;
   import Widgets.Slots.FaceOffVersusSlot;
   import Widgets.Windows.FaceOffWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.text.TextField;
   
   public class FaceOffFrame extends ZwFrame
   {
      
      private var m_currentStage:int;
      
      private var m_unlockedStage:int;
      
      private var m_window:FaceOffWindow;
      
      private var m_pickedStage:int;
      
      private var m_timeLeft:ZwTextField;
      
      private var m_resultsVariant:int;
      
      public function FaceOffFrame(element:DisplayObject, window:FaceOffWindow)
      {
         super(element);
         this.m_pickedStage = this.m_currentStage = FaceOffManager.getInstance().getCurrentStage();
         this.m_unlockedStage = this.m_pickedStage + 1;
         this.m_window = window;
         this.m_resultsVariant = Global.experimentManager.getExperimentVariant("fv_face_off_results_show");
         this.createStageIndicators();
         this.createSlots();
         if(m_element["header_tf"])
         {
            addWidget(new ZwTextField(m_element.header_tf,ZLocUtils.t("Dialogs","FaceOffGeneric_Header")));
         }
         if(m_element["timer_tf"])
         {
            this.m_timeLeft = new ZwTextField(m_element.timer_tf);
            addWidget(this.m_timeLeft);
         }
         if(m_element["subheader_tf"])
         {
            addWidget(new ZwTextField(m_element.subheader_tf,ZLocUtils.t("Dialogs","FaceOffGeneric_SubHeader")));
         }
         if(m_element["versus_mc"])
         {
            m_element["versus_mc"].visible = true;
         }
         this.update();
      }
      
      private function createSlots() : void
      {
         var numStages:int = 0;
         var slot_mc:MovieClip = m_element["slot_" + numStages + "_mc"];
         while(slot_mc)
         {
            addWidget(new FaceOffVersusSlot(slot_mc,"cow",this.m_window));
            getWidget(slot_mc).visible = false;
            numStages++;
            slot_mc = m_element["slot_" + numStages + "_mc"];
         }
         var numStagesPicked:int = 0;
         var slot_mcPicked:MovieClip = m_element["picked_" + numStagesPicked + "_mc"];
         while(slot_mcPicked)
         {
            addWidget(new FaceOffPickedSlot(slot_mcPicked,"horse",this.m_window));
            getWidget(slot_mcPicked).visible = false;
            numStagesPicked++;
            slot_mcPicked = m_element["picked_" + numStagesPicked + "_mc"];
         }
         var numSlotsNotPicked:int = 0;
         var slotNotPicked_mc:MovieClip = m_element["notpicked_" + numSlotsNotPicked + "_mc"];
         while(slotNotPicked_mc)
         {
            addWidget(new FaceOffNotPickedSlot(slotNotPicked_mc,"cow",this.m_window));
            getWidget(slotNotPicked_mc).visible = false;
            numSlotsNotPicked++;
            slotNotPicked_mc = m_element["notpicked_" + numSlotsNotPicked + "_mc"];
         }
         if(m_element["consolation_mc"])
         {
            addWidget(new FaceOffConsolationSlot(m_element["consolation_mc"],"cow",this.m_window));
         }
      }
      
      private function createStageIndicators() : void
      {
         var numStages:int = 1;
         var stage_mc:MovieClip = m_element["stage_" + numStages + "_bt"];
         while(stage_mc)
         {
            if(stage_mc["generic_tf"])
            {
               (stage_mc["generic_tf"] as TextField).text = String(numStages);
            }
            if(numStages <= this.m_unlockedStage && Boolean(stage_mc["lock_mc"]))
            {
               stage_mc["lock_mc"].visible = false;
            }
            addWidget(new FarmAnimatedButton(stage_mc,ZCacheUtil.applyPartial(this.stageClicked,this,[numStages - 1])));
            numStages++;
            stage_mc = m_element["stage_" + numStages + "_bt"];
         }
      }
      
      private function stageClicked(stage:int, event:Event) : void
      {
         if(stage < this.m_unlockedStage && stage != this.m_pickedStage)
         {
            this.m_pickedStage = stage;
            this.update();
         }
      }
      
      private function hideAllSlots() : void
      {
         var numSlots:int = 0;
         var emptySlots:String = "slot_" + numSlots + "_mc";
         var pickedSlots:String = "picked_" + numSlots + "_mc";
         var notPickedSlots:String = "notpicked_" + numSlots + "_mc";
         while(Boolean(m_element[emptySlots]) || Boolean(m_element[pickedSlots]) || Boolean(m_element[notPickedSlots]))
         {
            if(m_element[emptySlots])
            {
               getWidget(m_element[emptySlots]).visible = false;
            }
            if(m_element[pickedSlots])
            {
               getWidget(m_element[pickedSlots]).visible = false;
            }
            if(m_element[notPickedSlots])
            {
               getWidget(m_element[notPickedSlots]).visible = false;
            }
            emptySlots = "slot_" + numSlots + "_mc";
            pickedSlots = "picked_" + numSlots + "_mc";
            notPickedSlots = "notpicked_" + numSlots + "_mc";
            if(m_element["winner_" + numSlots + "_mc"])
            {
               m_element["winner_" + numSlots + "_mc"].visible = false;
            }
            if(m_element["looser_" + numSlots + "_mc"])
            {
               m_element["looser_" + numSlots + "_mc"].visible = false;
            }
            numSlots++;
         }
         if(m_element["consolation_mc"])
         {
            getWidget(m_element["consolation_mc"]).visible = false;
         }
      }
      
      private function showResultsMessage() : void
      {
         if(Boolean(m_element["subheader_tf"]) && this.m_currentStage != this.m_pickedStage)
         {
            getWidget(m_element["subheader_tf"]).visible = false;
            if(FaceOffManager.getInstance().getStagePicked(this.m_pickedStage) == FaceOffManager.getInstance().getWinningItem(this.m_pickedStage))
            {
               if(m_element["header_tf"])
               {
                  (getWidget(m_element["header_tf"]) as ZwTextField).text = ZLocUtils.t("Dialogs","FaceOffGeneric_WinnerMessage",{
                     "quantity":1,
                     "item":ZLocUtils.tk_pk("Items:" + FaceOffManager.getInstance().getWinningItem(this.m_pickedStage) + "_friendlyName")
                  });
               }
            }
            else if(m_element["header_tf"])
            {
               (getWidget(m_element["header_tf"]) as ZwTextField).text = ZLocUtils.t("Dialogs","FaceOffGeneric_ConsolationMessage",{
                  "quantity":1,
                  "item":ZLocUtils.tk_pk("Items:" + FaceOffManager.getInstance().getConsolationPrize(this.m_pickedStage) + "_friendlyName")
               });
            }
         }
         else if(FaceOffManager.getInstance().getStagePicked(this.m_pickedStage))
         {
            if(m_element["header_tf"])
            {
               (getWidget(m_element["header_tf"]) as ZwTextField).text = ZLocUtils.t("Dialogs","FaceOffGeneric_PickedMessage",{
                  "quantity":1,
                  "item":ZLocUtils.tk_pk("Items:" + FaceOffManager.getInstance().getStagePicked(this.m_pickedStage) + "_friendlyName")
               });
               (getWidget(m_element["subheader_tf"]) as ZwTextField).text = "";
            }
         }
         else
         {
            if(m_element["header_tf"])
            {
               (getWidget(m_element["header_tf"]) as ZwTextField).text = ZLocUtils.t("Dialogs","FaceOffGeneric_Header");
            }
            if(m_element["subheader_tf"])
            {
               m_element["subheader_tf"].visible = true;
               (getWidget(m_element["subheader_tf"]) as ZwTextField).text = ZLocUtils.t("Dialogs","FaceOffGeneric_SubHeader");
            }
         }
      }
      
      public function update() : void
      {
         var slot_mc:MovieClip = null;
         var slotPicked_mc:MovieClip = null;
         var stageItems:Array = FaceOffManager.getInstance().getStageItems(this.m_pickedStage);
         var stagePickedItem:String = FaceOffManager.getInstance().getStagePicked(this.m_pickedStage);
         this.hideAllSlots();
         this.showResultsMessage();
         if(this.m_pickedStage != this.m_currentStage)
         {
            this.m_timeLeft.visible = false;
         }
         else
         {
            this.m_timeLeft.visible = true;
         }
         var numStagesPicked:int = 0;
         if(m_element["slot_" + numStagesPicked + "_mc"])
         {
            slot_mc = m_element["slot_" + numStagesPicked + "_mc"];
         }
         while(slot_mc)
         {
            if(!stagePickedItem && this.m_currentStage == this.m_pickedStage)
            {
               (getWidget(slot_mc) as FaceOffVersusSlot).updateItem(stageItems[numStagesPicked]);
               getWidget(slot_mc).visible = true;
            }
            else
            {
               getWidget(slot_mc).visible = false;
            }
            numStagesPicked++;
            slot_mc = m_element["slot_" + numStagesPicked + "_mc"];
         }
         var numSlotsPicked:int = 0;
         if(m_element["picked_" + numSlotsPicked + "_mc"])
         {
            slotPicked_mc = m_element["picked_" + numSlotsPicked + "_mc"];
         }
         while(slotPicked_mc)
         {
            (getWidget(slotPicked_mc) as FaceOffPickedSlot).updateItem(stageItems[numSlotsPicked]);
            if((getWidget(slotPicked_mc) as FaceOffPickedSlot).getItemName() == stagePickedItem && Boolean(stagePickedItem))
            {
               getWidget(slotPicked_mc).visible = true;
               if(this.m_pickedStage != this.m_currentStage)
               {
                  (getWidget(slotPicked_mc) as FaceOffPickedSlot).toggleVotingButton(false);
                  if(this.m_resultsVariant == 3 && (getWidget(slotPicked_mc) as FaceOffPickedSlot).getItemName() == FaceOffManager.getInstance().getWinningItem(this.m_pickedStage))
                  {
                     (getWidget(slotPicked_mc) as FaceOffPickedSlot).setVoteText("Won");
                  }
                  else if(this.m_resultsVariant == 3 && (getWidget(slotPicked_mc) as FaceOffPickedSlot).getItemName() != FaceOffManager.getInstance().getWinningItem(this.m_pickedStage))
                  {
                     (getWidget(slotPicked_mc) as FaceOffPickedSlot).setVoteText("Lost");
                  }
                  if((getWidget(slotPicked_mc) as FaceOffPickedSlot).getItemName() == FaceOffManager.getInstance().getWinningItem(this.m_pickedStage))
                  {
                     if(m_element["winner_" + numSlotsPicked + "_mc"])
                     {
                        m_element["winner_" + numSlotsPicked + "_mc"].visible = true;
                     }
                  }
                  else if((getWidget(slotPicked_mc) as FaceOffPickedSlot).getItemName() != FaceOffManager.getInstance().getWinningItem(this.m_pickedStage))
                  {
                     if(m_element["looser_" + numSlotsPicked + "_mc"])
                     {
                        m_element["looser_" + numSlotsPicked + "_mc"].visible = true;
                     }
                  }
                  (getWidget(slotPicked_mc) as FaceOffPickedSlot).toggleResultsMessage(true);
               }
               else if(this.m_pickedStage == this.m_currentStage)
               {
                  if(this.m_resultsVariant == 3 && (getWidget(slotPicked_mc) as FaceOffPickedSlot).getItemName() == FaceOffManager.getInstance().getWinningItem(this.m_pickedStage))
                  {
                     (getWidget(slotPicked_mc) as FaceOffPickedSlot).setVoteText("Winning");
                  }
                  else if(this.m_resultsVariant == 3 && (getWidget(slotPicked_mc) as FaceOffPickedSlot).getItemName() != FaceOffManager.getInstance().getWinningItem(this.m_pickedStage))
                  {
                     (getWidget(slotPicked_mc) as FaceOffPickedSlot).setVoteText("Losing");
                  }
               }
               if(this.m_resultsVariant <= 2)
               {
                  (getWidget(slotPicked_mc) as FaceOffPickedSlot).setVoteText(FaceOffManager.getInstance().getVotePercentage((getWidget(slotPicked_mc) as FaceOffPickedSlot).getItemName()).toString() + "%");
               }
               if(this.m_resultsVariant <= 1 && this.m_currentStage == this.m_pickedStage)
               {
                  (getWidget(slotPicked_mc) as FaceOffPickedSlot).setVoteText("");
                  (getWidget(slotPicked_mc) as FaceOffPickedSlot).toggleResultsMessage(false);
               }
            }
            else
            {
               getWidget(slotPicked_mc).visible = false;
            }
            numSlotsPicked++;
            slotPicked_mc = m_element["picked_" + numSlotsPicked + "_mc"];
         }
         var numSlotsNotPicked:int = 0;
         var slotNotPicked_mc:MovieClip = m_element["notpicked_" + numSlotsNotPicked + "_mc"];
         while(slotNotPicked_mc)
         {
            (getWidget(slotNotPicked_mc) as FaceOffNotPickedSlot).updateItem(stageItems[numSlotsNotPicked]);
            if(Boolean((getWidget(slotNotPicked_mc) as FaceOffNotPickedSlot).getItemName() != stagePickedItem) && Boolean(stagePickedItem) || this.m_pickedStage != this.m_currentStage && !stagePickedItem)
            {
               getWidget(slotNotPicked_mc).visible = true;
               if(this.m_pickedStage != this.m_currentStage)
               {
                  if(this.m_resultsVariant == 3 && (getWidget(slotNotPicked_mc) as FaceOffNotPickedSlot).getItemName() == FaceOffManager.getInstance().getWinningItem(this.m_pickedStage))
                  {
                     (getWidget(slotNotPicked_mc) as FaceOffNotPickedSlot).setVoteText("Won");
                  }
                  else if(this.m_resultsVariant == 3 && (getWidget(slotNotPicked_mc) as FaceOffNotPickedSlot).getItemName() != FaceOffManager.getInstance().getWinningItem(this.m_pickedStage))
                  {
                     (getWidget(slotNotPicked_mc) as FaceOffNotPickedSlot).setVoteText("Lost");
                  }
                  if((getWidget(slotNotPicked_mc) as FaceOffNotPickedSlot).getItemName() == FaceOffManager.getInstance().getWinningItem(this.m_pickedStage))
                  {
                     if(m_element["winner_" + numSlotsNotPicked + "_mc"])
                     {
                        m_element["winner_" + numSlotsNotPicked + "_mc"].visible = true;
                     }
                  }
                  else if((getWidget(slotNotPicked_mc) as FaceOffNotPickedSlot).getItemName() != FaceOffManager.getInstance().getWinningItem(this.m_pickedStage))
                  {
                     if(m_element["looser_" + numSlotsNotPicked + "_mc"])
                     {
                        m_element["looser_" + numSlotsNotPicked + "_mc"].visible = true;
                        m_element["looser_" + numSlotsNotPicked + "_mc"]["title_tf"] = "Loser";
                     }
                  }
                  (getWidget(slotNotPicked_mc) as FaceOffNotPickedSlot).toggleResultsMessage(true);
               }
               else if(this.m_pickedStage == this.m_currentStage)
               {
                  if(this.m_resultsVariant == 3 && (getWidget(slotNotPicked_mc) as FaceOffNotPickedSlot).getItemName() == FaceOffManager.getInstance().getWinningItem(this.m_pickedStage))
                  {
                     (getWidget(slotNotPicked_mc) as FaceOffNotPickedSlot).setVoteText("Winning");
                  }
                  else if(this.m_resultsVariant == 3 && (getWidget(slotNotPicked_mc) as FaceOffNotPickedSlot).getItemName() != FaceOffManager.getInstance().getWinningItem(this.m_pickedStage))
                  {
                     (getWidget(slotNotPicked_mc) as FaceOffNotPickedSlot).setVoteText("Losing");
                  }
               }
               if(this.m_resultsVariant <= 2)
               {
                  (getWidget(slotNotPicked_mc) as FaceOffNotPickedSlot).setVoteText(FaceOffManager.getInstance().getVotePercentage((getWidget(slotNotPicked_mc) as FaceOffNotPickedSlot).getItemName()).toString() + "%");
               }
               if(this.m_resultsVariant <= 1 && this.m_currentStage == this.m_pickedStage)
               {
                  (getWidget(slotNotPicked_mc) as FaceOffNotPickedSlot).setVoteText("");
                  (getWidget(slotNotPicked_mc) as FaceOffNotPickedSlot).toggleResultsMessage(false);
               }
            }
            else
            {
               getWidget(slotNotPicked_mc).visible = false;
            }
            numSlotsNotPicked++;
            slotNotPicked_mc = m_element["notpicked_" + numSlotsNotPicked + "_mc"];
         }
         (getWidget(m_element["consolation_mc"]) as FaceOffConsolationSlot).updateItem(FaceOffManager.getInstance().getConsolationPrize(this.m_pickedStage));
         getWidget(m_element["consolation_mc"]).visible = true;
         var timeLeftString:String = FaceOffManager.getInstance().getTimeRemaining();
         this.m_timeLeft.text = ZLocUtils.t("Dialogs","FaceOffGeneric_TimeLeft",{"timeLeft":timeLeftString});
      }
   }
}

