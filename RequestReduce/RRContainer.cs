﻿using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;
using RequestReduce.Filter;
using RequestReduce.Reducer;
using StructureMap;

namespace RequestReduce
{
    public static class RRContainer
    {
        private static IContainer container = InitContainer();

        private static IContainer InitContainer()
        {
            var container = new Container();
            container.Configure(x =>
                                    {
                                        x.For<IReducingQueue>().Singleton().Use<ReducingQueue>();
                                        x.For<IReductionRepository>().Singleton().Use<ReductionRepository>().Ctor<IDictionary>("dictionary").Is(new Hashtable());
                                        x.For<HttpContextBase>().Use(() => HttpContext.Current == null ? null : new HttpContextWrapper(HttpContext.Current));
                                    });
            container.Configure(x => x.Scan(y =>
            {
                y.TheCallingAssembly();
                y.ExcludeType<ReductionRepository>();
                y.ExcludeType<ReducingQueue>();
                y.WithDefaultConventions();
            }
            ));
            container.Configure(
                x =>
                x.For<AbstractFilter>().Use(
                    y =>
                    HttpContext.Current == null
                        ? new ResponseFilter(null, Encoding.UTF8, y.GetInstance<IResponseTransformer>())
                        : new ResponseFilter(HttpContext.Current.Response.Filter, HttpContext.Current.Response.ContentEncoding, y.GetInstance<IResponseTransformer>())));
           return container;
        }

        public static IContainer Current
        {
            get { return container; }
            set { container = value; }
        }

    }
}
