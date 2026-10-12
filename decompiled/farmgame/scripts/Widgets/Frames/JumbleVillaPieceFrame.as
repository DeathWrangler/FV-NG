package Widgets.Frames
{
   import Managers.JumbleVillaManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Slots.JumbleVillaPieceSlot;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class JumbleVillaPieceFrame extends FarmSlotContainerFrame
   {
      
      protected static const SLOT_PREFIX:String = "piece";
      
      protected static const SLOT_POSTFIX:String = "_mc";
      
      private static const JUMBLEVILLA_STORY_REDEEM:String = "jumblevilla_story_redeem";
      
      protected var m_featureName:String = "JumbleVilla";
      
      private var m_tabs_mc:JumbleVillaTabsFrame;
      
      private var m_image_mc:MovieClip;
      
      private var m_complete_mc:MovieClip;
      
      private var m_okay_bt:FarmAnimatedTextButton;
      
      private var m_text_tf:ZwTextField;
      
      private var m_image_tooltip_mc:ZwFrame;
      
      public function JumbleVillaPieceFrame(element:DisplayObject)
      {
         super(element);
         element.visible = true;
         if(element.hasOwnProperty("tabs_mc"))
         {
            this.m_tabs_mc = new JumbleVillaTabsFrame(element["tabs_mc"]);
         }
         if(element.hasOwnProperty("image_mc"))
         {
            this.m_image_mc = element["image_mc"] as MovieClip;
            this.m_image_tooltip_mc = new ZwFrame(element["image_mc"]);
            this.m_image_mc.gotoAndStop(this.manager.getActivePuzzleId() + 1);
            this.m_image_mc.visible = true;
         }
         if(element.hasOwnProperty("complete_mc"))
         {
            this.m_complete_mc = element["complete_mc"] as MovieClip;
            this.m_complete_mc.visible = false;
            if(this.m_complete_mc.hasOwnProperty("okay_bt"))
            {
               this.m_okay_bt = new FarmAnimatedTextButton(this.m_complete_mc["okay_bt"],"Next Puzzle!",this.onClickPuzzleCompletedButton);
               this.m_okay_bt.visible = false;
            }
            if(this.m_complete_mc.hasOwnProperty("text_tf"))
            {
               addWidget(this.m_text_tf = new ZwTextField(this.m_complete_mc["text_tf"]));
            }
         }
      }
      
      private function updatePieceVisibility(clickedTab:int) : void
      {
         for(var i:int = 0; i < m_slotData.length; i++)
         {
            if(clickedTab == this.manager.getActivePuzzleId())
            {
               m_slots[i].visible = m_slotData[i].visible;
            }
            else
            {
               m_slots[i].visible = false;
            }
         }
      }
      
      public function showCompletedPuzzleFrame(clickedTab:int) : void
      {
         var completeText:String = null;
         if(this.m_complete_mc)
         {
            this.m_complete_mc.visible = true;
            if(this.m_okay_bt)
            {
               if(this.manager.isFeatureinActivePeriod())
               {
                  this.m_okay_bt.visible = !this.manager.isFeatureCompleted() && clickedTab == this.manager.getActivePuzzleId();
                  if(clickedTab == this.manager.getLastPuzzleId())
                  {
                     this.m_okay_bt.text = "Complete!";
                  }
               }
               else
               {
                  this.m_okay_bt.visible = !this.manager.isFeatureCompleted() && clickedTab == this.manager.getActivePuzzleId() && !Global.player.getSeenFlag("jumblevilla_story_redeem");
                  this.m_okay_bt.text = "Collect!";
               }
            }
            if(this.m_text_tf)
            {
               if(this.manager.isFeatureinActivePeriod())
               {
                  if(this.manager.isFeatureCompleted())
                  {
                     completeText = "Yay! Our storybook is complete. Thank you for your help. Stay tuned for more features!";
                  }
                  else if(clickedTab == this.manager.getActivePuzzleId())
                  {
                     completeText = "Awesome, This page is complete. Let’s start finding the pieces for the next page!";
                     if(clickedTab == this.manager.getLastPuzzleId())
                     {
                        completeText = "Yay! Our storybook is complete. Thank you for your help.";
                     }
                     this.m_okay_bt.visible = true;
                  }
                  else
                  {
                     completeText = "This page of the story is complete! Check the other pages of the story and complete them.";
                  }
               }
               else if(this.manager.isFeatureCompleted())
               {
                  completeText = "Yay! Our storybook is complete. Thank you for your help. Stay tuned for more features!";
               }
               else if(clickedTab == this.manager.getActivePuzzleId())
               {
                  if(!Global.player.getSeenFlag("jumblevilla_story_redeem"))
                  {
                     completeText = "Awesome, This page was completed. Collect the reward for this page!";
                  }
                  else
                  {
                     completeText = "Farmer, Jumblevilla is over, you did good! Stay Tuned for more features!";
                  }
               }
               else
               {
                  completeText = "Farmer, Jumblevilla is over, you did good! Stay Tuned for more features!";
               }
               this.m_text_tf.text = completeText;
               this.m_text_tf.visible = true;
            }
         }
      }
      
      private function onClickPuzzleCompletedButton(event:MouseEvent) : void
      {
         if(!this.manager.isFeatureinActivePeriod() && !Global.player.getSeenFlag("jumblevilla_story_redeem"))
         {
            Global.player.setSeenFlag("jumblevilla_story_redeem");
         }
         this.manager.markPuzzleCompleted();
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new JumbleVillaPieceSlot(slotElement);
      }
      
      override protected function setupData() : void
      {
         m_slotData = [];
         var puzzleData:Object = this.manager.getActivePuzzleData();
         var piecesData:Object = puzzleData["pieces"];
         for(var i:int = 0; i < m_slots.length; i++)
         {
            m_slotData.push({
               "visible":piecesData[i]["collected"] < piecesData[i]["required"],
               "progress":piecesData[i]["progress"],
               "collected":piecesData[i]["collected"],
               "required":piecesData[i]["required"]
            });
         }
      }
      
      override protected function getSlotPrefix() : String
      {
         return SLOT_PREFIX;
      }
      
      override protected function getSlotPostfix() : String
      {
         return SLOT_POSTFIX;
      }
      
      private function get manager() : JumbleVillaManager
      {
         return JumbleVillaManager.getInstance(this.m_featureName);
      }
      
      public function refreshPuzzlePieces(clickedTab:int) : void
      {
         this.setupData();
         refresh();
         this.updatePieceVisibility(clickedTab);
      }
      
      public function refreshFrame(clickedTab:int) : void
      {
         this.refreshPuzzlePieces(clickedTab);
         this.showPuzzleImage(clickedTab);
      }
      
      public function refreshNonPuzzleFrame(clickedTab:int) : void
      {
         this.refreshTabsFrame(clickedTab);
         if(clickedTab < this.manager.getActivePuzzleId() || this.manager.isActivePuzzleCompleted())
         {
            this.showCompletedPuzzleFrame(clickedTab);
         }
         else
         {
            this.showActivePuzzleFrame();
         }
      }
      
      private function refreshTabsFrame(clickedTab:int) : void
      {
         if(this.m_tabs_mc)
         {
            this.m_tabs_mc.refreshTabs(clickedTab);
         }
      }
      
      private function showPuzzleImage(clickedTab:int) : void
      {
         var visibility:Boolean = false;
         if(this.m_image_mc)
         {
            this.m_image_mc.gotoAndStop(clickedTab + 1);
            this.m_image_mc.visible = true;
         }
         if(this.m_image_tooltip_mc)
         {
            visibility = !this.manager.isActivePuzzleCompleted();
            this.m_image_tooltip_mc.detachTooltip();
            if(this.manager.isFeatureinActivePeriod() && visibility)
            {
               this.m_image_tooltip_mc.attachTooltip(new FarmTextTooltip("This piece is complete!"));
            }
            this.m_image_tooltip_mc.visible = true;
         }
      }
      
      private function showActivePuzzleFrame() : void
      {
         if(this.m_complete_mc)
         {
            this.m_complete_mc.visible = false;
            if(this.m_okay_bt)
            {
               this.m_okay_bt.visible = false;
            }
            if(this.m_text_tf)
            {
               this.m_text_tf.visible = false;
            }
         }
      }
   }
}

