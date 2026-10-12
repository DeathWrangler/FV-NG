package Classes
{
   public class AbstractMapResourceImageProgression
   {
      
      protected var m_resource:MapResource;
      
      public function AbstractMapResourceImageProgression(resource:MapResource)
      {
         super();
         this.m_resource = resource;
      }
      
      public function cleanUp() : void
      {
         this.m_resource = null;
      }
   }
}

