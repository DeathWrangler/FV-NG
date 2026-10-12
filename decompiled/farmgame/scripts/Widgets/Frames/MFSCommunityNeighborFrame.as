package Widgets.Frames
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Managers.CommunityMatchmakingUtility;
   import Managers.FeatureOptionsManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Slots.MFSCommunityNeighborSlot;
   import Widgets.Windows.MFSAddNeighbor;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class MFSCommunityNeighborFrame extends FarmSlotContainerFrame
   {
      
      private static const CN_SLOT_PREFIX:String = "comSlot_";
      
      protected var m_window:MFSAddNeighbor = null;
      
      protected var m_seeMore:FarmAnimatedButton = null;
      
      protected var m_addneighbors:FarmAnimatedButton = null;
      
      protected var m_loader:MovieClip = null;
      
      protected var m_body:ZwTextField = null;
      
      private var m_isOptedIn:Boolean;
      
      private var m_optInMC:MovieClip;
      
      public function MFSCommunityNeighborFrame(element:DisplayObject, window:MFSAddNeighbor)
      {
         var bodyText:String = null;
         var featureOption:Object = null;
         this.m_window = window;
         super(element);
         if(CommunityMatchmakingUtility.isInCommunityMatchmakingV3Experiment())
         {
            if(m_element.seeMore_bt)
            {
               m_element.seeMore_bt.visible = false;
            }
            if(m_element.optIn_mc)
            {
               this.m_optInMC = m_element.optIn_mc;
               if(Boolean(this.m_optInMC.optIn_tf) && Boolean(this.m_optInMC.checkmark_mc))
               {
                  addWidget(new ZwTextField(this.m_optInMC.optIn_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"CommunityMatchmakingOptInText")));
                  featureOption = FeatureOptionsManager.getInstance().getFeatureOption(CommunityMatchmakingUtility.FEATURE_NAME,CommunityMatchmakingUtility.FEATURE_OPTION_KEY_OPT_IN);
                  this.m_isOptedIn = featureOption === null || featureOption === true;
                  this.m_optInMC.visible = true;
                  this.m_optInMC.checkmark_mc.visible = this.m_isOptedIn;
                  this.m_optInMC.addEventListener(MouseEvent.CLICK,this.onOptInButtonClicked);
               }
            }
         }
         else
         {
            this.m_seeMore = addWidget(new FarmAnimatedButton(m_element.seeMore_bt,this.onPageForward)) as FarmAnimatedButton;
         }
         this.m_addneighbors = addWidget(new FarmAnimatedButton(m_element.addNeighbors_bt,this.m_window.addCommunityNeighborsCallback)) as FarmAnimatedButton;
         this.m_loader = m_element.loader_mc as MovieClip;
         if(CommunityMatchmakingUtility.isInCommunityMatchmakingV3Experiment())
         {
            bodyText = ZLocUtils.t("Dialogs","CommunityMatchmakingV3_CommunityNeighbors_Window_Subtitle");
         }
         else
         {
            bodyText = ZLocUtils.t("FarmVille","CommunityNeighbors_Window_Subtitle");
         }
         this.m_body = addWidget(new ZwTextField(m_element.body_tf,bodyText)) as ZwTextField;
      }
      
      private function onOptInButtonClicked(event:Event) : void
      {
         this.m_isOptedIn = !this.m_isOptedIn;
         this.m_optInMC.checkmark_mc.visible = this.m_isOptedIn;
         if(Global.flashHotParams["COMMUNITY_NEIGHBOR_OPTOUT"])
         {
            FeatureOptionsManager.getInstance().setFeatureOption(CommunityMatchmakingUtility.FEATURE_NAME,CommunityMatchmakingUtility.FEATURE_OPTION_KEY_OPT_IN,this.m_isOptedIn);
            FeatureOptionsManager.getInstance().saveSingleFeature(CommunityMatchmakingUtility.FEATURE_NAME,CommunityMatchmakingUtility.FEATURE_OPTION_KEY_OPT_IN);
         }
      }
      
      public function isOptedIn() : Boolean
      {
         return this.m_isOptedIn;
      }
      
      override protected function getSlotPrefix() : String
      {
         return CN_SLOT_PREFIX;
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new MFSCommunityNeighborSlot(slotElement);
      }
      
      public function onPageForward(event:Event) : void
      {
         this.m_loader.visible = true;
         this.m_loader.gotoAndPlay(1);
         this.m_loader.addEventListener(Event.ENTER_FRAME,this.onEnterFrame);
      }
      
      private function onEnterFrame(event:Event) : void
      {
         if(this.m_loader.currentFrame == this.m_loader.totalFrames)
         {
            this.stopSpinner();
            if(m_pagingComponent.currentPageNumber < m_pagingComponent.maxPageNumber)
            {
               m_pagingComponent.currentPageNumber += 1;
            }
            else
            {
               m_pagingComponent.currentPageNumber = 0;
            }
         }
      }
      
      public function stopSpinner() : void
      {
         if(this.m_loader)
         {
            this.m_loader.stop();
            this.m_loader.removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
            this.m_loader.visible = false;
         }
      }
      
      public function get items() : Array
      {
         return m_slotData;
      }
      
      public function set items(items:Array) : void
      {
         m_slotData = items;
         refresh();
      }
      
      override protected function setupData() : void
      {
      }
      
      public function getSelectedFriends() : Array
      {
         var slot:MFSCommunityNeighborSlot = null;
         var data:Object = null;
         var result:Array = new Array();
         for each(slot in m_slots)
         {
            if(slot.visible && slot.selected)
            {
               data = slot.data;
               if(data)
               {
                  result.push(data["uid"]);
               }
            }
         }
         return result;
      }
      
      public function disableAddNeighborButton() : void
      {
         this.m_addneighbors.enabled = false;
         this.m_body.text = ZLocUtils.t("FarmVille","CommunityNeighbors_SuggestionHub_LimitReached");
         this.m_body.visible = true;
      }
      
      override public function release() : void
      {
         this.m_seeMore = null;
         this.m_addneighbors = null;
         this.m_loader = null;
         if(this.m_optInMC)
         {
            this.m_optInMC.removeEventListener(MouseEvent.CLICK,this.onOptInButtonClicked);
            this.m_optInMC = null;
         }
         super.release();
      }
   }
}

