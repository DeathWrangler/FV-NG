package Widgets.Frames.Clubs
{
   import Classes.Constants.FarmClubConstants;
   import Classes.util.ZLocUtils;
   import Events.DynamicObjectEvent;
   import Managers.Clubs.DataObjects.BrowseClubObject;
   import Managers.Clubs.FarmClubDataManager;
   import Managers.Clubs.FarmClubUtility;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.Clubs.BrowseClubSlot;
   import Widgets.Windows.Clubs.FarmClubWindow2;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class BrowseClubSlotContainerFrame extends FarmSlotContainerFrame
   {
      
      private var m_browseClubData:BrowseClubObject = null;
      
      private var m_parentWindow:FarmClubWindow2 = null;
      
      private var m_loadingSpinner:ZwWidget = null;
      
      private var m_parentClose:FarmButton = null;
      
      private var m_callbackIndex:int = 0;
      
      public function BrowseClubSlotContainerFrame(element:DisplayObject, parentWindow:FarmClubWindow2, closeButton:FarmButton = null)
      {
         super(element);
         this.m_parentWindow = parentWindow;
         this.m_parentClose = closeButton;
         m_pageBackWidget = addWidget(new ZwButton(m_element.arrowUp_bt,m_pagingComponent.onPageBack),false) as ZwButton;
         m_pageForwardWidget = addWidget(new ZwButton(m_element.arrowDown_bt,m_pagingComponent.onPageForward),false) as ZwButton;
         this.m_browseClubData = FarmClubDataManager.getInstance().getBrowseClubObject();
         if(element.hasOwnProperty("header_tf"))
         {
            element["header_tf"].visible = true;
            element["header_tf"].text = ZLocUtils.t("FarmClub","BrowseClubHeader");
         }
         if(this.m_browseClubData == null)
         {
            this.m_loadingSpinner = new ZwWidget(m_element.loadingSpinner_mc);
            (this.m_loadingSpinner.element as MovieClip).gotoAndPlay(1);
            addWidget(this.m_loadingSpinner);
            this.m_callbackIndex = FarmClubDataManager.getInstance().registerCaller(FarmClubDataManager.BROWSE_CLUB_DATA,function(result:BrowseClubObject):void
            {
               FarmClubDataManager.getInstance().unregisterCaller(m_callbackIndex);
               m_browseClubData = result;
               items = m_browseClubData.data;
               (m_loadingSpinner.element as MovieClip).stop();
               m_loadingSpinner.visible = false;
            });
         }
         else
         {
            this.items = this.m_browseClubData.data;
         }
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new BrowseClubSlot(slotElement,this.onJoinCallback);
      }
      
      override protected function setupData() : void
      {
      }
      
      override public function release() : void
      {
         super.release();
         FarmClubDataManager.getInstance().unregisterCaller(this.m_callbackIndex);
         this.m_parentWindow = null;
         this.m_browseClubData = null;
         this.m_loadingSpinner = null;
         this.m_parentClose = null;
      }
      
      public function get numSlots() : int
      {
         return m_slots.length;
      }
      
      public function get items() : Array
      {
         return m_slotData;
      }
      
      public function set items(items:Array) : void
      {
         m_slotData = items;
         m_pagingComponent.reset();
         refresh();
      }
      
      private function onJoinCallback(clubId:String) : void
      {
         FarmClubUtility.canJoinClub(clubId,function(result:Boolean):void
         {
            if(result)
            {
               FarmClubUtility.joinClub(clubId,joinedClubCallback);
               if(m_loadingSpinner == null)
               {
                  m_loadingSpinner = new ZwWidget(m_element.loadingSpinner_mc);
                  addWidget(m_loadingSpinner);
               }
               (m_loadingSpinner.element as MovieClip).gotoAndPlay(1);
               m_loadingSpinner.visible = true;
               clearSlots();
               m_pageBackWidget.visible = false;
               m_pageForwardWidget.visible = false;
               m_parentClose.visible = false;
            }
         });
      }
      
      private function joinedClubCallback(result:Object) : void
      {
         this.m_parentWindow.close();
         FarmClubUtility.dispatcher.addEventListener(FarmClubConstants.CREATE_CLUB_EVENT,function(event:DynamicObjectEvent):void
         {
            FarmClubUtility.dispatcher.removeEventListener(FarmClubConstants.CREATE_CLUB_EVENT,arguments.callee);
            FarmClubUtility.showDialog();
         });
      }
   }
}

