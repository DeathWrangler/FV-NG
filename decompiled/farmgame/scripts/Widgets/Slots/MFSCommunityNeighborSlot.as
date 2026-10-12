package Widgets.Slots
{
   import Classes.Constants.MFSConstants;
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class MFSCommunityNeighborSlot extends ZwSlotFrame
   {
      
      private static const ICON_SIZE:int = 50;
      
      private var m_selected:Boolean = true;
      
      private var m_checkMark:MovieClip = null;
      
      private var m_checkBox:FarmAnimatedButton = null;
      
      private var m_country:ZwTextField = null;
      
      private var m_icon:FarmIcon = null;
      
      private var m_lastPlayed:ZwTextField = null;
      
      private var m_level:ZwTextField = null;
      
      private var m_mutualFriends:ZwWidget = null;
      
      private var m_mutualFriendsText:ZwTextField = null;
      
      private var m_name:ZwTextField = null;
      
      private var m_visitButton:FarmAnimatedButton = null;
      
      private var m_uid:String = "";
      
      private var m_data:Object;
      
      public function MFSCommunityNeighborSlot(element:DisplayObject)
      {
         super(element);
         this.m_checkMark = m_element.checkmark_mc as MovieClip;
         this.m_checkMark.mouseEnabled = true;
         this.m_checkMark.addEventListener(MouseEvent.CLICK,this.onClick);
         this.m_checkBox = addWidget(new FarmAnimatedButton(m_element.checkBox_mc,this.onClick)) as FarmAnimatedButton;
         this.m_icon = addWidget(new FarmIcon(m_element.icon_mc)) as FarmIcon;
         this.m_icon.setIconSize(ICON_SIZE,ICON_SIZE);
         this.m_name = addWidget(new ZwTextField(m_element.name_tf," ")) as ZwTextField;
         this.m_level = addWidget(new ZwTextField(m_element.level_tf," ")) as ZwTextField;
         this.m_mutualFriends = addWidget(new ZwWidget(m_element.mutualFriends_mc)) as ZwWidget;
         if(this.m_mutualFriends)
         {
            this.m_mutualFriendsText = addWidget(new ZwTextField(m_element.mutualFriends_mc.mutualFriends_tf," ")) as ZwTextField;
         }
         this.m_country = addWidget(new ZwTextField(m_element.country_tf," ")) as ZwTextField;
         this.m_lastPlayed = addWidget(new ZwTextField(m_element.lastplayed_tf," ")) as ZwTextField;
         this.m_visitButton = addWidget(new FarmAnimatedButton(m_element.visit_bt,this.onVisitFarm)) as FarmAnimatedButton;
      }
      
      public function onClick(event:MouseEvent) : void
      {
         this.m_checkMark.visible = this.m_selected = !this.m_selected;
      }
      
      public function get data() : Object
      {
         return this.m_data;
      }
      
      public function get selected() : Boolean
      {
         return this.m_selected;
      }
      
      private function onVisitFarm(event:Event) : void
      {
         Global.worldManager.visitNeighbor(this.m_uid.toString());
      }
      
      override public function populate(data:Object) : void
      {
         var maxLevelToDisplay:int = 0;
         var mutualFriends:String = null;
         var i:int = 0;
         var tooltip:FarmTextTooltip = null;
         super.populate(data);
         this.m_data = data;
         if(this.m_data)
         {
            this.m_checkMark.visible = this.m_selected = true;
            this.m_checkBox.visible = true;
            this.m_icon.loadIcon(data[MFSConstants.PIC_SQUARE]);
            this.m_visitButton.visible = false;
            this.m_icon.visible = true;
            this.m_name.text = data[MFSConstants.USER_NAME];
            this.m_name.visible = true;
            maxLevelToDisplay = int(Global.flashHotParams["R2_NEIGHBOR_MAX_LEVEL_DISPLAY"]);
            if(data.hasOwnProperty(MFSConstants.USER_LEVEL) && maxLevelToDisplay > 0 && maxLevelToDisplay > data[MFSConstants.USER_LEVEL])
            {
               this.m_level.text = data[MFSConstants.USER_LEVEL];
               this.m_level.visible = true;
            }
            this.m_uid = data["uid"];
            if(this.m_data.hasOwnProperty(MFSConstants.PLAYED_DAYS_AGO))
            {
               this.m_lastPlayed.text = this.getLastPlayedText(int(this.m_data[MFSConstants.PLAYED_DAYS_AGO]));
               this.m_lastPlayed.visible = true;
            }
            if(this.m_data.hasOwnProperty(MFSConstants.COUNTRY))
            {
               this.m_country.text = this.m_data[MFSConstants.COUNTRY];
               this.m_country.visible = true;
            }
            if(this.m_data.hasOwnProperty(MFSConstants.MUTUAL_FRIENDS_COUNT))
            {
               this.m_mutualFriends.visible = true;
               this.m_mutualFriendsText.text = ZLocUtils.t("FarmVille","CommunityNeighbors_SuggestionHub_MutualFriends",{"count":data[MFSConstants.MUTUAL_FRIENDS_COUNT].toString()});
               this.m_mutualFriendsText.visible = true;
            }
            if(this.m_data.hasOwnProperty(MFSConstants.MUTUAL_FRIENDS))
            {
               mutualFriends = "";
               for(i = 0; i < (this.m_data[MFSConstants.MUTUAL_FRIENDS] as Array).length; i++)
               {
                  mutualFriends += this.m_data[MFSConstants.MUTUAL_FRIENDS][i]["name"].toString() + "\n";
               }
               if(int(data[MFSConstants.MUTUAL_FRIENDS_COUNT]) > 10)
               {
                  mutualFriends += ZLocUtils.t("FarmVille","CommunityNeighbors_MutualFriendsDisplayMax",{"extraFriends":int(data[MFSConstants.MUTUAL_FRIENDS_COUNT]) - 10});
               }
               if(mutualFriends != "")
               {
                  tooltip = new FarmTextTooltip();
                  tooltip.setText(mutualFriends);
                  this.m_mutualFriendsText.attachTooltip(tooltip);
               }
            }
         }
      }
      
      public function getLastPlayedText(days:int) : String
      {
         var result:String = "";
         if(days <= 3)
         {
            result = ZLocUtils.t("FarmVille","Community_Neighbor_highly_active");
         }
         else if(days <= 7)
         {
            result = ZLocUtils.t("FarmVille","Community_Neighbor_very_active");
         }
         else if(days <= 10)
         {
            result = ZLocUtils.t("FarmVille","Community_Neighbor_active");
         }
         else
         {
            result = ZLocUtils.t("FarmVille","Community_Neighbor_moderatly_active");
         }
         return result;
      }
      
      override public function release() : void
      {
         this.m_data = null;
         this.m_checkBox = null;
         this.m_checkMark = null;
         this.m_name = null;
         this.m_level = null;
         this.m_uid = null;
         this.m_visitButton = null;
         super.release();
      }
   }
}

