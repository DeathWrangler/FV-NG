package Widgets.Tooltips
{
   import Classes.Constants.Experiments;
   import Classes.FarmGameObject;
   import Classes.Growable.GrowableConstants;
   import Classes.Growable.GrowableContest;
   import Classes.Growable.GrowableInstanceDataProxy;
   import Classes.Growable.IGrowableResource;
   import Classes.util.ObjectUtil;
   import Display.UI;
   import Engine.Classes.Observer.IObserver;
   import Engine.Helpers.Vector3;
   import Engine.IsoMath;
   import Managers.FreezeManager;
   import Managers.GrowableContestManager;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Tooltips.Growable.GrowableObjectTooltipDefaultFrame;
   import Widgets.Tooltips.Growable.GrowableObjectTooltipHoverFrame;
   import Widgets.Tooltips.Growable.GrowableObjectTooltipPartnerVisitFrame;
   import Widgets.Windows.HoverOverWindow;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.geom.Rectangle;
   import flash.utils.Timer;
   
   public class GrowableObjectToolTip extends HoverOverWindow implements IObserver
   {
      
      protected static const DEFAULT_WINDOW_ASSET:String = "assets/dialogs/FV_SocialPig_tooltip.swf";
      
      private static const HOVER_MENU_TIME_MS:int = 800;
      
      private var m_growableResource:IGrowableResource = null;
      
      private var m_contest:GrowableContest;
      
      private var m_hoverTooltip:GrowableObjectTooltipHoverFrame;
      
      private var m_defaultTooltip:GrowableObjectTooltipDefaultFrame;
      
      private var m_partnerTooltip:GrowableObjectTooltipPartnerVisitFrame;
      
      private var m_hitArea:Rectangle;
      
      private var m_defaultTooltipBaseY:Number;
      
      private var m_closeHoverFrameTimer:Timer = new Timer(HOVER_MENU_TIME_MS,1);
      
      private var m_isTargetMoving:Boolean;
      
      private var m_isActive:Boolean;
      
      private var m_isPositioned:Boolean;
      
      private var m_isShowing:Boolean;
      
      private var m_shouldBeShowing:Boolean;
      
      private var m_minWorldZoom:Number = 0;
      
      public function GrowableObjectToolTip(originPoint:Vector3, growable:IGrowableResource)
      {
         this.m_growableResource = growable;
         this.m_contest = GrowableContestManager.instance.getContestForInstance(growable);
         this.m_closeHoverFrameTimer.addEventListener(TimerEvent.TIMER_COMPLETE,this.onCloseHoverFrameTimeout);
         var windowAssetRelUrl:String = null;
         if(this.m_contest)
         {
            windowAssetRelUrl = this.m_contest.getAssetUrl(GrowableContest.ASSET_KEY_TOOLTIP);
         }
         if(!windowAssetRelUrl)
         {
            windowAssetRelUrl = DEFAULT_WINDOW_ASSET;
         }
         super(originPoint,windowAssetRelUrl,HOVER_MENU_TIME_MS);
      }
      
      public static function checkToolTipGate() : Boolean
      {
         return Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_GROWABLE_CONTEST_TOOLTIP_ZOOM) != 3;
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(ObjectUtil.pathExists(m_window,"main_mc"))
         {
            this.m_hoverTooltip = new GrowableObjectTooltipHoverFrame(m_window.main_mc,this.m_growableResource);
            if(this.m_hoverTooltip.backgroundWidget)
            {
               this.m_hitArea = this.m_hoverTooltip.backgroundWidget.element.getBounds(m_window);
            }
            addWidget(this.m_hoverTooltip);
         }
         if(ObjectUtil.pathExists(m_window,"accept_mc"))
         {
            this.m_partnerTooltip = new GrowableObjectTooltipPartnerVisitFrame(m_window.accept_mc,this.m_growableResource);
            addWidget(this.m_partnerTooltip);
         }
         if(ObjectUtil.pathExists(m_window,"default_mc"))
         {
            this.m_defaultTooltip = new GrowableObjectTooltipDefaultFrame(m_window.default_mc,this.m_growableResource);
            if(this.m_hitArea)
            {
               this.m_defaultTooltipBaseY = this.m_hitArea.bottom - this.m_defaultTooltip.y;
            }
            addWidget(this.m_defaultTooltip);
         }
         GrowableInstanceDataProxy.getInstanceForResource(this.m_growableResource).addEventListener(GrowableConstants.EVENT_DATA_CHANGED,this.handleInstanceDataChanged);
         GrowableInstanceDataProxy.getInstanceForResource(this.m_growableResource).addEventListener(GrowableConstants.EVENT_STAGE_CHANGED,this.handleInstanceStageChanged);
         this.m_contest.addEventListener(GrowableContest.getParticipantCompletedEventName(this.m_growableResource.persistentDataKey),this.handleContestCompletion);
         this.m_growableResource.growableMapResource.addObserver(this,Vector.<String>([FarmGameObject.OBSERVABLE_EVENT_MOVE,FarmGameObject.OBSERVABLE_EVENT_PLACE]));
         this.m_minWorldZoom = 0;
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_GROWABLE_CONTEST_TOOLTIP_ZOOM) == 2)
         {
            if(Global.flashHotParams["GROWABLE_CONTEST_TOOLTIP_ZOOM_MIN"])
            {
               this.m_minWorldZoom = 0.02 * Global.flashHotParams["GROWABLE_CONTEST_TOOLTIP_ZOOM_MIN"];
            }
         }
         this.alignWindowOrigin();
         this.show();
         this.showIdleState();
      }
      
      private function handleInstanceDataChanged(e:Event) : void
      {
         if(visible && !this.m_growableResource.isPartOfContest())
         {
            this.hide();
            visible = false;
         }
         else
         {
            this.show();
            visible = true;
            if(this.m_isActive)
            {
               this.showHoverState();
            }
            else
            {
               this.showIdleState();
            }
         }
      }
      
      private function handleInstanceStageChanged(e:Event) : void
      {
         if(this.m_growableResource.isPartOfContest())
         {
            this.refreshVisibility();
         }
      }
      
      private function handleContestCompletion(e:Event) : void
      {
         this.hide();
         visible = false;
      }
      
      public function hideAllFrames() : void
      {
         this.showFrame(null);
      }
      
      private function showFrame(selectedFrame:ZwFrame) : void
      {
         var frame:Object = null;
         for each(frame in [this.m_defaultTooltip,this.m_hoverTooltip,this.m_partnerTooltip])
         {
            if(frame)
            {
               if(frame == selectedFrame && GlobalEngine.viewport.getZoom() >= this.m_minWorldZoom)
               {
                  frame.show();
                  frame.refreshUI();
               }
               else
               {
                  frame.hide();
               }
            }
         }
      }
      
      private function showIdleState() : void
      {
         this.m_isActive = false;
         if(this.hasPendingPartnerAction())
         {
            this.showFrame(this.m_partnerTooltip);
         }
         else
         {
            this.showFrame(this.m_defaultTooltip);
         }
      }
      
      private function showHoverState() : void
      {
         this.m_isActive = true;
         this.m_closeHoverFrameTimer.stop();
         this.m_closeHoverFrameTimer.reset();
         if(this.hasPendingPartnerAction())
         {
            this.showFrame(this.m_partnerTooltip);
         }
         else
         {
            this.showFrame(this.m_hoverTooltip);
         }
         UI.bringToFront(this);
      }
      
      private function hasPendingPartnerAction() : Boolean
      {
         var result:Boolean = false;
         var tmpContestEntry:Object = this.contestEntry;
         if(tmpContestEntry != null && tmpContestEntry.hasOwnProperty("pendingPartnerAction"))
         {
            result = Boolean(tmpContestEntry.pendingPartnerAction);
         }
         return result;
      }
      
      public function onCloseHoverFrameTimeout(e:TimerEvent) : void
      {
         this.showIdleState();
      }
      
      public function onItemMouseOver() : void
      {
         if(!UI.isShowingPopup())
         {
            this.showHoverState();
         }
      }
      
      public function onItemMouseOut() : void
      {
         this.m_closeHoverFrameTimer.start();
      }
      
      override protected function mouseOver(e:MouseEvent) : void
      {
         if(!UI.isShowingPopup())
         {
            this.showHoverState();
         }
         super.mouseOver(e);
      }
      
      override protected function mouseOut(e:MouseEvent) : void
      {
         this.m_closeHoverFrameTimer.start();
      }
      
      override public function show() : void
      {
         this.m_shouldBeShowing = true;
         if(this.m_isPositioned)
         {
            this.m_isShowing = true;
            super.show();
         }
      }
      
      override public function hide() : void
      {
         this.m_shouldBeShowing = false;
         super.hide();
      }
      
      public function updatePosition(originPoint:Vector3) : void
      {
         updateOrigin(originPoint);
         this.alignWindowOrigin();
      }
      
      override protected function alignWindowOrigin() : void
      {
         var zoomScale:Number = NaN;
         var posX:int = 0;
         var posY:int = 0;
         if(Boolean(this.m_hitArea && this.m_hoverTooltip && this.m_defaultTooltip) && Boolean(this.m_growableResource != null) && this.m_growableResource.growableMapResource.getImage() != null)
         {
            m_displayPoint = IsoMath.viewportToStage(IsoMath.tilePosToPixelPos(m_originPoint.x,m_originPoint.y));
            zoomScale = 0.5 * GlobalEngine.viewport.getZoom();
            posX = m_displayPoint.x - this.m_hoverTooltip.x - m_offsetX;
            posY = m_displayPoint.y - (zoomScale * this.m_growableResource.growableMapResource.getImage().height + this.m_hitArea.height);
            if(this.m_defaultTooltip.element)
            {
               this.m_defaultTooltip.element.scaleX = zoomScale;
               this.m_defaultTooltip.element.scaleY = zoomScale;
               this.m_defaultTooltip.y = this.m_hitArea.bottom - this.m_defaultTooltipBaseY * zoomScale;
            }
            setAbsolutePos(posX,posY,true);
            this.m_isPositioned = true;
            if(this.m_shouldBeShowing && !this.m_isShowing)
            {
               this.show();
            }
            this.showIdleState();
         }
      }
      
      private function refreshVisibility() : void
      {
         if(!this.m_isTargetMoving)
         {
            this.updatePosition(this.m_growableResource.growableMapResource.getPosition());
            this.show();
         }
         else
         {
            this.hide();
         }
      }
      
      public function detach() : void
      {
         this.m_growableResource.growableMapResource.removeObserver(this,Vector.<String>([FarmGameObject.OBSERVABLE_EVENT_MOVE,FarmGameObject.OBSERVABLE_EVENT_PLACE]));
         GrowableInstanceDataProxy.getInstanceForResource(this.m_growableResource).removeEventListener(GrowableConstants.EVENT_DATA_CHANGED,this.handleInstanceDataChanged);
         GrowableInstanceDataProxy.getInstanceForResource(this.m_growableResource).removeEventListener(GrowableConstants.EVENT_STAGE_CHANGED,this.handleInstanceStageChanged);
         this.m_contest.removeEventListener(GrowableContest.getParticipantCompletedEventName(this.m_growableResource.persistentDataKey),this.handleContestCompletion);
         if(this.m_defaultTooltip)
         {
            this.m_defaultTooltip.release();
         }
         if(this.m_hoverTooltip)
         {
            this.m_hoverTooltip.release();
         }
         if(this.m_partnerTooltip)
         {
            this.m_partnerTooltip.release();
         }
         this.m_growableResource = null;
         if(parent != null)
         {
            parent.removeChild(this);
         }
         else
         {
            FreezeManager.removeFrozenPopup(this);
         }
      }
      
      public function notify(event:String, data:Object) : void
      {
         if(this.m_growableResource.isPartOfContest())
         {
            switch(event)
            {
               case FarmGameObject.OBSERVABLE_EVENT_MOVE:
                  if(Boolean(data.obj) && data.obj == this.m_growableResource)
                  {
                     this.m_isTargetMoving = true;
                     this.refreshVisibility();
                  }
                  break;
               case FarmGameObject.OBSERVABLE_EVENT_PLACE:
                  if(Boolean(data.obj) && data.obj == this.m_growableResource)
                  {
                     this.m_isTargetMoving = false;
                     this.refreshVisibility();
                  }
            }
         }
      }
      
      override protected function release() : void
      {
         this.m_hoverTooltip.release();
         this.m_defaultTooltip.release();
         this.m_partnerTooltip.release();
         this.m_hoverTooltip = null;
         this.m_defaultTooltip = null;
         this.m_partnerTooltip = null;
         this.m_hitArea = null;
         this.m_growableResource = null;
         this.m_closeHoverFrameTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.onCloseHoverFrameTimeout);
         this.m_closeHoverFrameTimer = null;
         super.release();
      }
      
      private function get contestEntry() : Object
      {
         return this.m_contest.getContestEntryForKey(this.m_growableResource.persistentDataKey);
      }
      
      private function get instanceData() : Object
      {
         return this.m_growableResource.getGrowableInstanceData();
      }
   }
}

