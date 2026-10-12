package Widgets.Slots
{
   import Classes.Constants.MFSConstants;
   import Classes.util.ZLocUtils;
   import Managers.CommunityMatchmakingUtility;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.MFSAddNeighbor;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class MFSCurrentNeighborSlot extends ZwSlotFrame
   {
      
      private static const ICON_SIZE:int = 30;
      
      private var m_communityBG:ZwWidget = null;
      
      private var m_clickCallback:Function;
      
      private var m_data:Object;
      
      private var m_selected:Boolean = true;
      
      private var m_activeBackground:ZwWidget = null;
      
      private var m_checkbox:ZwWidget;
      
      private var m_icon:FarmIcon;
      
      private var m_nameTextField:ZwTextField;
      
      private var m_level:ZwTextField;
      
      private var m_removeMC:FarmButton = null;
      
      private var m_parentWindow:MFSAddNeighbor = null;
      
      public function MFSCurrentNeighborSlot(element:DisplayObject, clickCallback:Function, parentWindow:MFSAddNeighbor)
      {
         super(element);
         this.m_parentWindow = parentWindow;
         this.m_clickCallback = clickCallback;
         if(m_element.standardBG_mc)
         {
            this.m_activeBackground = addWidget(new ZwWidget(m_element.standardBG_mc)) as ZwWidget;
         }
         this.m_communityBG = addWidget(new ZwWidget(m_element.communityBG_mc)) as ZwWidget;
         this.m_icon = addWidget(new FarmIcon(m_element.mc_fbprofile)) as FarmIcon;
         this.m_icon.setIconSize(ICON_SIZE,ICON_SIZE);
         this.m_nameTextField = addWidget(new ZwTextField(m_element.txt_name," ")) as ZwTextField;
         if(m_element.level_tf)
         {
            this.m_level = addWidget(new ZwTextField(m_element.level_tf," ")) as ZwTextField;
         }
         if(CommunityMatchmakingUtility.isInCommunityMatchmakingV3Experiment())
         {
            addWidget(new FarmButton(element,this.onClickRemove),false);
         }
         this.m_removeMC = addWidget(new FarmButton(m_element.x_mc,this.onClickRemove)) as FarmButton;
         (m_element as MovieClip).addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
         (m_element as MovieClip).addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
      }
      
      override public function populate(data:Object) : void
      {
         var playedDaysAgo:String = null;
         var maxLevelToDisplay:int = 0;
         super.populate(data);
         this.m_data = data;
         if(this.m_data)
         {
            if(this.m_data.hasOwnProperty(MFSConstants.NEIGHBOR_TYPE))
            {
               if(this.m_data[MFSConstants.NEIGHBOR_TYPE] == "n")
               {
                  this.m_activeBackground.visible = true;
               }
               else
               {
                  this.m_communityBG.visible = true;
               }
            }
            this.m_icon.loadIcon(data[MFSConstants.PIC_SQUARE]);
            this.m_icon.visible = true;
            this.m_nameTextField.text = data[MFSConstants.USER_NAME];
            this.m_nameTextField.visible = true;
            if(CommunityMatchmakingUtility.isInCommunityMatchmakingV3Experiment())
            {
               if(m_element.mc_checkmark)
               {
                  m_element.mc_checkmark.visible = false;
               }
               playedDaysAgo = "";
               if(!data.played_days_ago || data.played_days_ago > 10)
               {
                  playedDaysAgo += ZLocUtils.t("FarmVille","Community_Neighbor_moderatly_active");
               }
               else if(data.played_days_ago <= 3)
               {
                  playedDaysAgo += ZLocUtils.t("FarmVille","Community_Neighbor_highly_active");
               }
               else if(data.played_days_ago <= 7)
               {
                  playedDaysAgo += ZLocUtils.t("FarmVille","Community_Neighbor_very_active");
               }
               else
               {
                  playedDaysAgo += ZLocUtils.t("FarmVille","Community_Neighbor_active");
               }
               this.m_level.text = playedDaysAgo;
               this.m_level.visible = true;
               if(data.multiDelete)
               {
                  this.m_removeMC = null;
                  (m_element as MovieClip).removeEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
                  (m_element as MovieClip).removeEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
                  if(Boolean(data.autoSelect) && Boolean(m_element.mc_checkmark) && !m_element.mc_checkmark.visible)
                  {
                     this.onClickRemove();
                  }
               }
            }
            else
            {
               maxLevelToDisplay = int(Global.flashHotParams["R2_NEIGHBOR_MAX_LEVEL_DISPLAY"]);
               if(data.hasOwnProperty(MFSConstants.USER_LEVEL) && maxLevelToDisplay > 0 && maxLevelToDisplay > data[MFSConstants.USER_LEVEL])
               {
                  this.m_level.text = ZLocUtils.t("Dialogs","MFSWindow_level",{"level":data[MFSConstants.USER_LEVEL]});
                  this.m_level.visible = true;
               }
            }
         }
      }
      
      public function get data() : Object
      {
         return this.m_data;
      }
      
      override public function release() : void
      {
         super.release();
      }
      
      private function onClickRemove(event:MouseEvent = null) : void
      {
         if(this.m_data)
         {
            if(CommunityMatchmakingUtility.isInCommunityMatchmakingV3Experiment() && Boolean(this.m_data.multiDelete))
            {
               if(m_element.mc_checkmark)
               {
                  m_element.mc_checkmark.visible = !m_element.mc_checkmark.visible;
               }
            }
            this.m_clickCallback(this.m_data);
         }
      }
      
      private function onMouseOver(event:MouseEvent) : void
      {
         this.m_removeMC.visible = true;
      }
      
      private function onMouseOut(event:MouseEvent) : void
      {
         this.m_removeMC.visible = false;
      }
      
      public function setNeighborRemoved() : void
      {
         if(this.m_data.hasOwnProperty(MFSConstants.NEIGHBOR_TYPE))
         {
            if(this.m_data[MFSConstants.NEIGHBOR_TYPE] == "n")
            {
               this.m_activeBackground.visible = false;
            }
            else
            {
               this.m_communityBG.visible = false;
            }
         }
      }
   }
}

