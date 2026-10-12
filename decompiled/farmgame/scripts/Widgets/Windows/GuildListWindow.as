package Widgets.Windows
{
   import Managers.GuildManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.GuildListFrame;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class GuildListWindow extends FarmWindow
   {
      
      public static const ICON_SIZE:int = 50;
      
      private static const FEATURE_NAME:String = "FVGuild";
      
      private var m_featureName:String = null;
      
      private const TITLE_TF:String = "title_tf";
      
      private var m_guildInfo:Object = null;
      
      private var m_searchBar_mc:MovieClip;
      
      private var m_searchField:ZwTextField;
      
      private var m_searchHit_bt:FarmAnimatedButton;
      
      private var m_coopListFrame:GuildListFrame;
      
      private var m_clearSearchHit_bt:FarmAnimatedButton;
      
      private var m_searchAttribute:String = "name";
      
      private var m_checkbox1_tf:ZwTextField;
      
      private var m_checkbox2_tf:ZwTextField;
      
      private var m_checkMark1:MovieClip;
      
      private var m_checkMark2:MovieClip;
      
      private var m_selectBt1:FarmButton;
      
      private var m_selectBt2:FarmButton;
      
      private var m_search_mc:MovieClip;
      
      private var m_canClearSearch:Boolean = true;
      
      private var m_justClearedSearch:Boolean = false;
      
      public const GUILD_LIST_SEEN_FLAG:String = "Guild_List_flag";
      
      private var m_npcAutoMc:MovieClip;
      
      private var m_npcAutoTalkMc:MovieClip;
      
      private var m_npcAuto1Tf:ZwTextField;
      
      private var m_npcAuto2Tf:ZwTextField;
      
      private var m_disableSearch:Boolean = true;
      
      public function GuildListWindow(featureName:String, assetUrl:String, result:Object)
      {
         this.m_featureName = featureName;
         this.m_guildInfo = result;
         super(assetUrl);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            addWidget(new ZwTextField(m_window[this.TITLE_TF],"Clans List"));
         }
         if(m_window.hasOwnProperty("checkbox1_tf"))
         {
            this.m_checkbox1_tf = new ZwTextField(m_window["checkbox1_tf"],"Search by Name");
            this.m_checkbox1_tf.visible = true;
         }
         if(m_window.hasOwnProperty("checkbox2_tf"))
         {
            this.m_checkbox2_tf = new ZwTextField(m_window["checkbox2_tf"],"Search by ID");
            this.m_checkbox2_tf.visible = true;
         }
         if(m_window.hasOwnProperty("select1_bt"))
         {
            addWidget(this.m_selectBt1 = new FarmButton(m_window["select1_bt"],this.onSelect1Click));
            this.m_checkMark1 = m_window["select1_bt"]["mc_checkmark"] as MovieClip;
            this.m_checkMark1.visible = true;
         }
         if(m_window.hasOwnProperty("select2_bt"))
         {
            addWidget(this.m_selectBt2 = new FarmButton(m_window["select2_bt"],this.onSelect2Click));
            this.m_checkMark2 = m_window["select2_bt"]["mc_checkmark"] as MovieClip;
            this.m_checkMark2.visible = false;
         }
         if(m_window.hasOwnProperty("searchBar_mc"))
         {
            addWidget(this.m_searchHit_bt = new FarmAnimatedTextButton(m_window["search_bt"],"Search",this.onSearchHit));
            this.m_searchHit_bt.visible = true;
         }
         if(m_window.hasOwnProperty("searchBar_mc"))
         {
            this.m_searchBar_mc = m_window["searchBar_mc"] as MovieClip;
            this.m_searchBar_mc.visible = true;
            if(this.m_searchBar_mc)
            {
               addWidget(this.m_searchField = new ZwTextField(this.m_searchBar_mc["searchField_tf"],"Search Clan"));
               this.m_searchField.visible = true;
               this.m_searchField.alpha = 0.3;
            }
            this.m_search_mc = this.m_searchBar_mc["search_mc"] as MovieClip;
            this.m_search_mc.visible = false;
            addWidget(this.m_clearSearchHit_bt = new FarmAnimatedButton(this.m_searchBar_mc["clearsearch_bt"],this.onClearSearchHit));
            this.m_clearSearchHit_bt.visible = false;
         }
         if(m_window.hasOwnProperty("coops_mc"))
         {
            this.m_coopListFrame = new GuildListFrame(m_window["coops_mc"],this.m_featureName);
            this.m_coopListFrame.visible = true;
         }
         if(m_window.hasOwnProperty("npc_auto_mc"))
         {
            this.m_npcAutoMc = m_window.npc_auto_mc as MovieClip;
            this.m_npcAutoMc.visible = false;
            if(this.m_npcAutoMc.hasOwnProperty("talk_mc"))
            {
               this.m_npcAutoTalkMc = this.m_npcAutoMc.talk_mc as MovieClip;
               this.m_npcAutoTalkMc.visible = true;
               this.m_npcAuto1Tf = new ZwTextField(this.m_npcAutoTalkMc["npc1_tf"]," Auto npc1");
               this.m_npcAuto2Tf = new ZwTextField(this.m_npcAutoTalkMc["npc2_tf"],"Auto Default NPC Text");
            }
         }
         if(!Global.player.getSeenFlag(this.GUILD_LIST_SEEN_FLAG))
         {
            this.showAutoHideNPCCallouts("Choice of Clans!","You can see a list of clans you can join, here. Search by name of a clan or its unique ID, your choice!");
            Global.player.setSeenFlag(this.GUILD_LIST_SEEN_FLAG);
         }
         this.m_searchBar_mc.addEventListener(MouseEvent.CLICK,this.clearSearchFields());
      }
      
      private function onSelect1Click(e:Event) : void
      {
         this.m_checkMark2.visible = false;
         this.m_checkMark1.visible = true;
         this.m_searchAttribute = "name";
      }
      
      private function onSelect2Click(e:Event) : void
      {
         this.m_checkMark1.visible = false;
         this.m_checkMark2.visible = true;
         this.m_searchAttribute = "guildId";
      }
      
      public function onSearchHit(e:Event) : void
      {
         var searchText:String = this.m_searchField.text;
         if(!(searchText == null || searchText == "" || this.m_disableSearch))
         {
            this.m_clearSearchHit_bt.visible = true;
            GuildManager.getInstance().searchGuilds(searchText,this.m_searchAttribute);
            tintWindow();
            enableInput = false;
         }
      }
      
      public function onClearSearchHit(e:Event) : void
      {
         this.m_disableSearch = true;
         this.m_searchField.text = "Search Clans";
         this.m_canClearSearch = true;
         this.m_searchField.alpha = 0.3;
         this.m_clearSearchHit_bt.visible = false;
         this.m_coopListFrame.setupSlotData(GuildManager.getInstance().getGuildListData());
         this.m_coopListFrame.refresh();
         this.m_justClearedSearch = true;
      }
      
      override public function refreshWindow() : void
      {
         super.refreshWindow();
         this.m_coopListFrame.refresh();
      }
      
      override public function close() : void
      {
         GuildManager.getInstance().m_guildListWindow = null;
         super.close();
      }
      
      public function setGuildListData(guildListData:Array) : void
      {
         this.m_coopListFrame.setupSlotData(guildListData);
      }
      
      override protected function onClose(event:Event) : void
      {
         super.onClose(event);
         GuildManager.getInstance().showUI();
      }
      
      private function clearSearchFields() : Function
      {
         return function(evt:MouseEvent):void
         {
            if(m_justClearedSearch == false)
            {
               if(m_canClearSearch)
               {
                  m_searchField.text = "";
                  m_canClearSearch = false;
                  m_searchField.alpha = 1;
                  m_disableSearch = false;
               }
            }
            else
            {
               m_justClearedSearch = false;
            }
         };
      }
      
      public function showAutoHideNPCCallouts(title:String, text:String) : void
      {
         this.m_npcAuto1Tf.text = title;
         this.m_npcAuto2Tf.text = text;
         this.m_npcAutoMc.visible = true;
         this.m_npcAutoMc.gotoAndPlay(1);
      }
   }
}

