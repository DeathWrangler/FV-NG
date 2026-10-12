package Classes.AreasOfEffect
{
   import Classes.MapResource;
   import Engine.Classes.AOEWorldObject;
   import com.infomatiq.jsi.RectangleUtil;
   import flash.geom.Rectangle;
   
   public class AOEIntersection
   {
      
      private var m_sourceResource:MapResource;
      
      private var m_sourceArea:AOEWorldObject;
      
      private var m_intersectResource:MapResource;
      
      private var m_intersectArea:AOEWorldObject;
      
      private var m_rect:Rectangle;
      
      private var m_commonTargets:Array;
      
      public function AOEIntersection(sourceResource:MapResource, intersectResource:MapResource, sourceArea:AOEWorldObject, intersectArea:AOEWorldObject, rect:Rectangle, commonTargets:Array)
      {
         super();
         this.m_sourceResource = sourceResource;
         this.m_sourceArea = sourceArea;
         this.m_intersectResource = intersectResource;
         this.m_intersectArea = intersectArea;
         this.m_rect = RectangleUtil.clone(rect);
         this.m_commonTargets = commonTargets;
      }
      
      public function get sourceResource() : MapResource
      {
         return this.m_sourceResource;
      }
      
      public function get sourceArea() : AOEWorldObject
      {
         return this.m_sourceArea;
      }
      
      public function get intersectResource() : MapResource
      {
         return this.m_intersectResource;
      }
      
      public function get intersectArea() : AOEWorldObject
      {
         return this.m_intersectArea;
      }
      
      public function get rect() : Rectangle
      {
         return this.m_rect;
      }
      
      public function get commonTargets() : Array
      {
         return this.m_commonTargets;
      }
   }
}

