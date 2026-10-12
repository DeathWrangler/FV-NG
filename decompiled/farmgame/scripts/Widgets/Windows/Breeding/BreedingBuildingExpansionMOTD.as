package Widgets.Windows.Breeding
{
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Windows.FarmWindow;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.geom.Point;
   
   public class BreedingBuildingExpansionMOTD extends FarmWindow
   {
      
      protected var m_breedingExpansionSlotFrame:BreedingBuildingExpansionMOTDSlotFrame;
      
      protected var m_toasterFrame:ZwFrame;
      
      protected var m_toasterTextField:ZwTextField;
      
      protected var m_boughtCallback:Function;
      
      protected var m_closeCallback:Function;
      
      public function BreedingBuildingExpansionMOTD(boughtCallback:Function, closeCallback:Function)
      {
         this.m_boughtCallback = boughtCallback;
         this.m_closeCallback = closeCallback;
         super("assets/dialogs/FV_animal_penExpand.swf");
      }
      
      override public function getDialogOffset() : Point
      {
         return new Point(0,22);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         addWidget(new FarmTextField(m_window.title_tf,ZLocUtils.t("Dialogs","MOTD_AnimalBreedingExpansions_Title")));
         addWidget(new FarmTextField(m_window.body_1_tf,ZLocUtils.t("Dialogs","MOTD_AnimalBreedingExpansions_SubTitle2")));
         this.m_breedingExpansionSlotFrame = addWidget(new BreedingBuildingExpansionMOTDSlotFrame(m_window.slotFrame_mc)) as BreedingBuildingExpansionMOTDSlotFrame;
         this.m_breedingExpansionSlotFrame.addEventListener(BreedingBuildingExpansionMOTDSlot.BUY_BUILDING_CLICKED_EVENT,this.onBuyBuildingClick);
         this.m_breedingExpansionSlotFrame.addEventListener(BreedingBuildingExpansionMOTDSlot.BUY_EXPANSION_CLICKED_EVENT,this.onBuyExpansionClick);
         FarmStatsManager.count("dialog","animal_breeding_expand_MOTD","view");
         this.m_toasterFrame = new ZwFrame(m_window.popup_mc);
         var thankyouMc:ZwFrame = new ZwFrame(this.m_toasterFrame.element.thankyou_mc);
         this.m_toasterTextField = new ZwTextField(thankyouMc.element.thankyou_tf,ZLocUtils.t("Dialogs","AnimalBreedingToasterBuilding"));
         thankyouMc.addWidget(this.m_toasterTextField);
         this.m_toasterFrame.addWidget(thankyouMc);
      }
      
      override public function close() : void
      {
         super.close();
         FarmStatsManager.count("dialog","animal_breeding_expand_MOTD","X");
         if(this.m_closeCallback != null)
         {
            this.m_closeCallback();
         }
      }
      
      private function onBuyBuildingClick(event:Event) : void
      {
         (this.m_toasterFrame.element as MovieClip).thankyou_mc.thankyou_tf.text = ZLocUtils.t("Dialogs","AnimalBreedingToasterBuilding");
         var currentToasterFrame:int = (this.m_toasterFrame.element as MovieClip).currentFrame;
         if(currentToasterFrame == 1 || currentToasterFrame == (this.m_toasterFrame.element as MovieClip).totalFrames)
         {
            (this.m_toasterFrame.element as MovieClip).visible = true;
            (this.m_toasterFrame.element as MovieClip).gotoAndPlay(2);
         }
         if(this.m_boughtCallback != null)
         {
            this.m_boughtCallback();
         }
      }
      
      private function onBuyExpansionClick(event:Event) : void
      {
         (this.m_toasterFrame.element as MovieClip).thankyou_mc.thankyou_tf.text = ZLocUtils.t("Dialogs","AnimalBreedingToasterExpansion");
         var currentToasterFrame:int = (this.m_toasterFrame.element as MovieClip).currentFrame;
         if(currentToasterFrame == 1 || currentToasterFrame == (this.m_toasterFrame.element as MovieClip).totalFrames)
         {
            (this.m_toasterFrame.element as MovieClip).visible = true;
            (this.m_toasterFrame.element as MovieClip).gotoAndPlay(2);
         }
         if(this.m_boughtCallback != null)
         {
            this.m_boughtCallback();
         }
      }
   }
}

